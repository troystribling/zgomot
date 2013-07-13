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
      find_iac_destination_index
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
      Interface.MIDISend(@output_port, get_destination_for_index(@iac_index), packet_list)
    end

    def add_input(name)
      remove_input(name) if @input
      src_index = find_source_index_for_name(name)
      src = get_source_for_index(src_index)
      Interface::MIDIPortConnectSource(@input_port, src, nil)
      @input = name
    end

    def remove_input(name)
      src_index = find_source_index_for_name(name)
      src = get_source_for_index(src_index)
      Interface::MIDIPortDisconnectSource(@input_endpoint, src)
      @input = nil
    end

    private

      def load_destinations
        Interface.MIDIGetNumberOfDestinations().times do |i|
          destination_ptr = get_destination_for_index(i)
          (@destinations ||= []) << get_property(:model, destination_ptr)
        end
      end

      def load_sources
        Interface.MIDIGetNumberOfSources().times do |i|
          source_ptr = get_source_for_index(i)
          (@sources ||= []) << get_property(:model, source_ptr)
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

      def find_iac_destination_index
        @iac_index = find_destination_index_for_name('IAC Driver')
        @output = @destinations[@iac_index]
        raise(Zgomot::Error, "IAC Driver not found") if @iac_index.nil?
      end

      def get_property(name, from)
        prop = Interface::CFString.CFStringCreateWithCString(nil, name.to_s, 0)
        val = Interface::CFString.CFStringCreateWithCString(nil, name.to_s, 0)
        Interface::MIDIObjectGetStringProperty(from, prop, val)
        Interface::CFString.CFStringGetCStringPtr(val.read_pointer, 0).read_string
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
        Interface::MIDIInputPortCreate(@input_client, port_name, @input_callback, nil, inport_ptr)
        @input_port = inport_ptr.read_pointer
      end

      def get_destination_for_index(index)
        Interface::MIDIGetDestination(index)
      end

      def get_source_for_index(index)
        Interface::MIDIGetSource(index)
      end

      def get_input_callback
        Proc.new do |new_packets, refCon, connRefCon|
          puts "MIDI MESSAGE RECEIVED"
        end
      end

  end

end
