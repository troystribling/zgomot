##############################################################################################################
module Zgomot::Midi

  #####-------------------------------------------------------------------------------------------------------
  class Time

    #.........................................................................................................
    attr_reader :measure, :note, :tick
  
    #.........................................................................................................
    def initialize
      @measure = 0
      @note = 0
      @tick = 0
    end

    #.........................................................................................................
    def to_s
      "#{measure}.#{note}.#{tick}"
    end
    
    #.........................................................................................................
    def to_sec 
      measure*Clock.measure_length + note*Clock.beat_length + tick*Clock.tick_length     
    end

  #### Time
  end

  #####-------------------------------------------------------------------------------------------------------
  class Clock

    #####-------------------------------------------------------------------------------------------------------
    class << self

      #.........................................................................................................
      @beats_per_measure, @beat_note = Zgomot.config[:time_signature].split('/').map{|v| v.to_f}
      @beats_per_minute = Zgomot.config[:beats_per_minute].to_f
      @whole_note_ticks = 2*Zgomot.config[:resolution].split('/').last.to_f
      @beat_length = 60./@beats_per_minute
      @whole_note_length = @beat_length*@beat_note
      @measure_length = @beat_length*@beats_per_measure
      @tick_length = @whole_note_length/(2*@min_note)

      #.........................................................................................................
      attr_reader :clocks, :beat_note, :beats_per_measure, :beats_per_minute, :min_note, :tick_length,
                  :seconds_per_beat, :whole_note_ticks, :whole_note_length
          
    #### self
    end
    
    #####-------------------------------------------------------------------------------------------------------
    
    #.........................................................................................................
    def update(ticks)
    end


  #### Clock
  end

#### Zgomot ::Midi
end
