class Zgomot::Drivers

  class CoreMidi < Driver

    attr_reader :destinations, :sources, :input, :output

    # API Wrapper
    module Interface

      extend FFI::Library
      ffi_lib '/System/Library/Frameworks/CoreMIDI.framework/Versions/Current/CoreMIDI'

      typedef :pointer, :CFStringRef
      typedef :int32,   :ItemCount
      typedef :pointer, :MIDIClientRef
      typedef :pointer, :MIDIDeviceRef
      typedef :pointer, :MIDIEntityRef
      typedef :pointer, :MIDIObjectRef
      typedef :pointer, :MIDIEndpointRef
      typedef :uint32,  :MIDITimeStamp
      typedef :pointer, :MIDIPortRef
      typedef :int32,   :OSStatus

      class MIDIPacket < FFI::Struct
        layout :timestamp,  :MIDITimeStamp,
               :nothing,    :uint32,
               :length,     :uint16,
               :data,       [:uint8, 256]
      end

      class MIDIPacketList < FFI::Struct
        layout :numPackets,   :uint32,
               :packet,       [MIDIPacket.by_value, 1]
      end

      callback :MIDIReadProc, [MIDIPacketList.by_ref, :pointer, :pointer], :pointer

      attach_function :MIDIClientCreate, [:pointer, :pointer, :pointer, :pointer], :OSStatus
      attach_function :MIDIGetNumberOfDevices, [], :ItemCount
      attach_function :MIDIGetNumberOfDestinations, [], :ItemCount
      attach_function :MIDIGetNumberOfSources, [], :ItemCount
      attach_function :MIDIClientDispose, [:MIDIClientRef], :OSStatus
      attach_function :MIDIDeviceGetEntity, [:MIDIDeviceRef, :ItemCount], :MIDIEntityRef
      attach_function :MIDIGetDestination, [:ItemCount], :MIDIEndpointRef
      attach_function :MIDIGetSource, [:ItemCount], :MIDIEndpointRef
      attach_function :MIDIGetDevice, [:ItemCount], :MIDIDeviceRef
      attach_function :MIDIOutputPortCreate, [:MIDIClientRef, :CFStringRef, :MIDIPortRef], :OSStatus
      attach_function :MIDIInputPortCreate, [:MIDIClientRef, :CFStringRef, :MIDIReadProc, :pointer, :MIDIPortRef], :OSStatus
      attach_function :MIDIObjectGetStringProperty, [:MIDIObjectRef, :CFStringRef, :CFStringRef], :OSStatus
      attach_function :MIDIPacketListInit, [:pointer], MIDIPacket.by_ref
      attach_function :MIDIPacketListAdd, [:pointer, :int, :pointer, :int, :int, :pointer], :pointer
      attach_function :MIDISend, [:MIDIPortRef, :MIDIEndpointRef, :pointer], :OSStatus
      attach_function :MIDIReceived, [:MIDIEndpointRef, :pointer], :OSStatus
      attach_function :MIDIPortConnectSource, [:MIDIPortRef, :MIDIEndpointRef, :pointer], :OSStatus
      attach_function :MIDIPortDisconnectSource, [:MIDIPortRef, :MIDIEndpointRef], :OSStatus

      module CFString
        extend FFI::Library
        ffi_lib '/System/Library/Frameworks/CoreFoundation.framework/Versions/Current/CoreFoundation'
        attach_function :CFStringCreateWithCString, [:pointer, :string, :int], :pointer
        attach_function :CFStringGetCStringPtr, [:pointer, :int], :pointer
      end

    end

    # Driver
    def initialize
      load_destinations
      load_sources
      find_iac_destination
      @input_client = create_client('Input-Client')
      @output_client = create_client('Output-Client')
      create_output_port
      create_input_port
    end

    def close
      Map.MIDIClientDispose(@client)
    end

    def write(*data)
      size = data.size
      format = "C" * size
      bytes = FFI::MemoryPointer.new(FFI.type_size(:char) * size)
      bytes.write_string(data.pack(format))
      packet_list = FFI::MemoryPointer.new(256)
      packet_ptr = Interface.MIDIPacketListInit(packet_list)
      packet_ptr = Interface.MIDIPacketListAdd(packet_list, 256, packet_ptr, 0, size, bytes)
      Interface.MIDISend(@output_port, @destination, packet_list)
    end

    def add_input(name)
      remove_input(name) if @input
      src_index = find_source_index_for_name(name)
      src = Interface.MIDIGetSource(src_index)
      Interface::MIDIPortConnectSource(@input_port, src, nil)
      @input = name
    end

    def remove_input(name)
      src_index = find_source_index_for_name(name)
      src = Interface.MIDIGetSource(src_index)
      Interface::MIDIPortDisconnectSource(@input_endpoint, src)
      @input = nil
    end

    private

      def load_destinations
        @destinations = (0..(Interface.MIDIGetNumberOfDestinations()-1)).reduce([]) do |dest, i|
                          destination_ptr = Interface.MIDIGetDestination(i)
                          dest << get_entity_name(destination_ptr)
                        end
      end

      def load_sources
        @sources = (0..(Interface.MIDIGetNumberOfSources()-1)).reduce([]) do |src, i|
                     source_ptr = Interface.MIDIGetSource(i)
                     src << get_entity_name(source_ptr)
                   end
      end

      def find_destination_index_for_name(name)
        dest_index = (0..(@destinations.length-1)).find{|i| @destinations[i] == name}
        dest_index.nil? ? raise(Zgomot::Error, "Destination '#{name}' not found") : dest_index
      end

      def find_source_index_for_name(name)
        src_index = (0..(@sources.length-1)).find{|i| @sources[i] == name}
        src_index.nil? ? raise(Zgomot::Error, "Source '#{name}' not found") : src_index
      end

      def find_iac_destination
        iac_index = find_destination_index_for_name('IAC Driver')
        @destination = Interface.MIDIGetDestination(iac_index)
        @output = @destinations[iac_index]
      end

      def get_entity_name(from)
        name = get_property(:model, from)
        name.nil? ? (get_property(:name, from) || 'Unknown') : name
      end

      def get_property(name, from)
        prop = Interface::CFString.CFStringCreateWithCString(nil, name.to_s, 0)
        val_ptr = FFI::MemoryPointer.new(:pointer)
        Interface::MIDIObjectGetStringProperty(from, prop, val_ptr)
        if val_ptr.read_pointer.address > 0
          Interface::CFString.CFStringGetCStringPtr(val_ptr.read_pointer, 0).read_string
        else
          nil
        end
      end

      def create_client(name)
        client_name = Interface::CFString.CFStringCreateWithCString(nil, name, 0)
        client_ptr = FFI::MemoryPointer.new(:pointer)
        Interface.MIDIClientCreate(client_name, nil, nil, client_ptr)
        client_ptr.read_pointer
      end

      def create_output_port
        port_name = Interface::CFString.CFStringCreateWithCString(nil, "Output-Port", 0)
        outport_ptr = FFI::MemoryPointer.new(:pointer)
        Interface::MIDIOutputPortCreate(@output_client, port_name, outport_ptr)
        @output_port = outport_ptr.read_pointer
      end

      def create_input_port
        port_name = Interface::CFString.CFStringCreateWithCString(nil, "Input-Port", 0)
        inport_ptr = FFI::MemoryPointer.new(:pointer)
        @input_callback = get_input_callback
        Interface.MIDIInputPortCreate(@input_client, port_name, @input_callback, nil, inport_ptr)
        @input_port = inport_ptr.read_pointer
      end

      def get_input_callback
        ->(new_packets, refCon, connRefCon) do
          packet = new_packets[:packet][0]
          len = packet[:length]
          if len > 0
            bytes = packet[:data].to_a[0, len]
            message_type = bytes.first
            if message_type >= CC and message_type <= (CC | 0xf)
              channel = message_type - CC
              Zgomot::Midi::CC.apply(bytes[1], bytes[2], channel)
            end
          end
        end
      end

  end

end
