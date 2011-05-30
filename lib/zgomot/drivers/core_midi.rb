##############################################################################################################
class Zgomot::Drivers

  #####-------------------------------------------------------------------------------------------------------
  class CoreMidi < Driver

    #-------------------------------------------------------------------------------------------------------
    attr_reader :input

    #---------------------------------------------------------------------------------------------------------
    module Interface

      #-------------------------------------------------------------------------------------------------------
      extend FFI::Library
      ffi_lib '/System/Library/Frameworks/CoreMIDI.framework/Versions/Current/CoreMIDI'

      ####...................................
      typedef :pointer, :CFStringRef
      typedef :int32,   :ItemCount
      typedef :pointer, :MIDIClientRef
      typedef :pointer, :MIDIDeviceRef
      typedef :pointer, :MIDIEntityRef
      typedef :pointer, :MIDIObjectRef
      typedef :int32,   :OSStatus

      ####...................................
      attach_function :MIDIClientCreate, [:pointer, :pointer, :pointer, :pointer], :int
      attach_function :MIDIClientDispose, [:pointer], :int
      attach_function :MIDIDeviceGetEntity, [:MIDIDeviceRef, :ItemCount], :MIDIEntityRef
      attach_function :MIDIGetDestination, [:int], :pointer
      attach_function :MIDIGetDevice, [:ItemCount], :MIDIDeviceRef
      attach_function :MIDIOutputPortCreate, [:MIDIClientRef, :CFStringRef, :pointer], :int
      attach_function :MIDIObjectGetStringProperty, [:MIDIObjectRef, :CFStringRef, :pointer], :OSStatus
      attach_function :MIDIPacketListInit, [:pointer], :pointer
      attach_function :MIDIPacketListAdd, [:pointer, :int, :pointer, :int, :int, :pointer], :pointer
      attach_function :MIDISend, [:pointer, :pointer, :pointer], :int
 
      #-------------------------------------------------------------------------------------------------------
      module CFString

        ####...................................
        extend FFI::Library
        ffi_lib '/System/Library/Frameworks/CoreFoundation.framework/Versions/Current/CoreFoundation'

        ####...................................
        attach_function :CFStringCreateWithCString, [:pointer, :string, :int], :pointer
        attach_function :CFStringGetCStringPtr, [:pointer, :int], :pointer

      #### CFString
      end

    #### Interface
    end

    #---------------------------------------------------------------------------------------------------------
    # instance methods
    #---------------------------------------------------------------------------------------------------------
    def initialize
      find_iac_device
      get_entity
      create_client
      connect_endpoint
      get_destination
    end

    #---------------------------------------------------------------------------------------------------------
    # Driver API
    #---------------------------------------------------------------------------------------------------------
    def close
      Map.MIDIClientDispose(@client)
    end

    #---------------------------------------------------------------------------------------------------------
    def write(*data)

      ####...................................
      size = data.size
      format = "C" * size
      bytes = (FFI::MemoryPointer.new FFI.type_size(:char) * size)
      bytes.write_string(data.pack(format))
      
      ####...................................
      packet_list = FFI::MemoryPointer.new(256)
      packet_ptr = Interface.MIDIPacketListInit(packet_list)

      ####...................................
      packet_ptr = Interface.MIDIPacketListAdd(packet_list, 256, packet_ptr, 0, size, bytes)

      ####...................................
      Interface.MIDISend(@endpoint, @destination, packet_list)

    end

    #---------------------------------------------------------------------------------------------------------
    # Utils
    #---------------------------------------------------------------------------------------------------------
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

    #---------------------------------------------------------------------------------------------------------
    def get_entity
      @entity = Interface.MIDIDeviceGetEntity(@device, 0)
      raise(Zgomot::Error, "Driver initialization failed") unless @entity
    end
    
    #---------------------------------------------------------------------------------------------------------
    def get_property(name, from = @device)
      prop = Interface::CFString.CFStringCreateWithCString(nil, name.to_s, 0)
      val = Interface::CFString.CFStringCreateWithCString(nil, name.to_s, 0)
      Interface::MIDIObjectGetStringProperty(from, prop, val)
      Interface::CFString.CFStringGetCStringPtr(val.read_pointer, 0).read_string
    end

    #---------------------------------------------------------------------------------------------------------
    def create_client
      client_name = Interface::CFString.CFStringCreateWithCString(nil, "Client #{@id}: #{@name}", 0)
      client_ptr = FFI::MemoryPointer.new(:pointer)
      Interface.MIDIClientCreate(client_name, nil, nil, client_ptr)
      @client = client_ptr.read_pointer
    end

    #---------------------------------------------------------------------------------------------------------
    def connect_endpoint
      port_name = Interface::CFString.CFStringCreateWithCString(nil, "Port #{@id}: #{@name}", 0)
      outport_ptr = FFI::MemoryPointer.new(:pointer)
      Interface.MIDIOutputPortCreate(@client, port_name, outport_ptr)
      @endpoint = outport_ptr.read_pointer
    end

    #---------------------------------------------------------------------------------------------------------
    def get_destination
      @destination = Interface.MIDIGetDestination(0)
    end
    
  #### CoreMidi
  end

#### Zgomot::Drivers
end
