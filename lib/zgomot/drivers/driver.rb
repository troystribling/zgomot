class Zgomot::Drivers

  class Driver

    #---------------------------------------------------------------------------------------------------------
    # MIDI commands
    #---------------------------------------------------------------------------------------------------------
    # Note on
    ON  = 0x90

    # Note off
    OFF = 0x80

    # Polyphonic aftertouch
    PA  = 0xa0

    # Control change
    CC  = 0xb0

    # Program change
    PC  = 0xc0

    # Channel aftertouch
    CA  = 0xd0

    # Pitch bend
    PB  = 0xe0

    def initialize
      open
    end

    def note_on(note, channel, velocity)
      write(ON | channel, note, velocity)
    end

    def note_off(note, channel, velocity = 0)
      write(OFF | channel, note, velocity)
    end

    def aftertouch(note, channel, pressure)
      write(PA | channel, note, pressure)
    end

    def control_change(number, channel, value)
      write(CC | channel, number, value)
    end

    def program_change(channel, program)
      write(PC | channel, program)
    end

    def channel_aftertouch(channel, pressure)
      write(CA | channel, pressure)
    end

    def pitch_bend(channel, value)
      write(PB | channel, value)
    end

    #---------------------------------------------------------------------------------------------------------
    # Driver API
    #---------------------------------------------------------------------------------------------------------
    def close
      raise NotImplementedError, "You must implement #close in your driver."
    end

    def write(*args)
      raise NotImplementedError, "You must implement #write in your driver."
    end

  end

end
