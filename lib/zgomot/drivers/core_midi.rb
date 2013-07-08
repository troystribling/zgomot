class Zgomot::Drivers

  class CoreMidi < Driver

    attr_reader :input

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
      typedef :uint32, :MIDITimeStamp
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
      attach_function :MIDIClientDispose, [:MIDIClientRef], :OSStatus
      attach_function :MIDIDeviceGetEntity, [:MIDIDeviceRef, :ItemCount], :MIDIEntityRef
      attach_function :MIDIGetDestination, [:ItemCount], :MIDIEndpointRef
      attach_function :MIDIGetDevice, [:ItemCount], :MIDIDeviceRef
      attach_function :MIDIOutputPortCreate, [:MIDIClientRef, :CFStringRef, :MIDIPortRef], :OSStatus
      #attach_function :MIDIInputPortCreate, [:MIDIClientRef, :CFStringRef, :MIDIReadProc, :pointer, :MIDIPortRef], :int
      attach_function :MIDIObjectGetStringProperty, [:MIDIObjectRef, :CFStringRef, :CFStringRef], :OSStatus
      attach_function :MIDIPacketListInit, [:pointer], :pointer
      attach_function :MIDIPacketListAdd, [:pointer, :int, :pointer, :int, :int, :pointer], :pointer
      attach_function :MIDISend, [:MIDIPortRef, :MIDIEndpointRef, :pointer], :OSStatus
      attach_function :MIDIReceived, [:MIDIEndpointRef, :pointer], :OSStatus

      module CFString
        extend FFI::Library
        ffi_lib '/System/Library/Frameworks/CoreFoundation.framework/Versions/Current/CoreFoundation'
        attach_function :CFStringCreateWithCString, [:pointer, :string, :int], :pointer
        attach_function :CFStringGetCStringPtr, [:pointer, :int], :pointer
      end

    end

    # Driver
    def initialize
      find_iac_device
      get_entity
      create_client
      connect_output_endpoint
      get_destination
    end

    def close
      Map.MIDIClientDispose(@client)
    end

    def write(*data)
      size = data.size
      format = "C" * size
      bytes = (FFI::MemoryPointer.new FFI.type_size(:char) * size)
      bytes.write_string(data.pack(format))
      packet_list = FFI::MemoryPointer.new(256)
      packet_ptr = Interface.MIDIPacketListInit(packet_list)
      packet_ptr = Interface.MIDIPacketListAdd(packet_list, 256, packet_ptr, 0, size, bytes)
      Interface.MIDISend(@output_endpoint, @destination, packet_list)
    end

    def find_iac_device
      i, entity_counter, @device = 0, 0, nil
      while !(device_pointer = Interface.MIDIGetDevice(i)).null?
        device_model = get_property(:model, device_pointer)
        if device_model.eql?('IAC Driver')
          @device = device_pointer
          break
        end
      end
      raise(Zgomot::Error, "IAC Driver not found") unless @device
    end

    def get_entity
      @entity = Interface.MIDIDeviceGetEntity(@device, 0)
      raise(Zgomot::Error, "Driver initialization failed") unless @entity
    end

    def get_property(name, from = @device)
      prop = Interface::CFString.CFStringCreateWithCString(nil, name.to_s, 0)
      val = Interface::CFString.CFStringCreateWithCString(nil, name.to_s, 0)
      Interface::MIDIObjectGetStringProperty(from, prop, val)
      Interface::CFString.CFStringGetCStringPtr(val.read_pointer, 0).read_string
    end

    def create_client
      client_name = Interface::CFString.CFStringCreateWithCString(nil, "Client", 0)
      client_ptr = FFI::MemoryPointer.new(:pointer)
      Interface.MIDIClientCreate(client_name, nil, nil, client_ptr)
      @client = client_ptr.read_pointer
    end

    def connect_output_endpoint
      port_name = Interface::CFString.CFStringCreateWithCString(nil, "Port", 0)
      outport_ptr = FFI::MemoryPointer.new(:pointer)
      Interface.MIDIOutputPortCreate(@client, port_name, outport_ptr)
      @output_endpoint = outport_ptr.read_pointer
    end

    def connect_input_endpoint
      #port_name = Interface::CFString.CFStringCreateWithCString(nil, "Port", 0)
      #outport_ptr = FFI::MemoryPointer.new(:pointer)
      #Interface.MIDIOutputPortCreate(@client, port_name, outport_ptr)
      #@input_endpoint = outport_ptr.read_pointer
    end

    def get_destination
      @destination = Interface.MIDIGetDestination(0)
    end

  end

end
