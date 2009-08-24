##############################################################################################################
module Zgomot::Comp

  #####-------------------------------------------------------------------------------------------------------
  class Key
     
    #.........................................................................................................
    attr_reader :tonic, :mode
  
    #.........................................................................................................
    def initialize(tonic, mode)
      @mode = mode.kind_of?(Mode) ? mode : Mode.new(mode)
      @tonic = tonic
    end

    #.........................................................................................................
    def pitches
      get_pitches
    end

  private
  
    #.........................................................................................................
    def get_pitches
      pitch = [tonic.first]
      mode[0..-2].each_index do |i| 
        pitch << PitchClass.next(tonic.first, sum(mode[0..i]))
      end
      octave = tonic.last
      pitch[1..-1].map do |p| 
        [p.value, (p < :B ? octave : (octave+1))]
      end.unshift(tonic)
    end
    
    #.........................................................................................................
    def sum(a)
      a.inject(0) {|s,n| s+n}
    end
  
  #### Key
  end

  #####-------------------------------------------------------------------------------------------------------
  class KeyNote
    
    #.........................................................................................................
    attr_reader :pitch_class, :length, :octave, :midi, :velocity
    attr_accessor :time, :offset_time, :channel
  
    #.........................................................................................................
    def initialize(n)
      @offset_time = n[:offset_time] || 0.0
      @channel, @time = n[:channel], n[:time]
      @pitch_class, @octave = n[:pitch]
      @length, @velocity = n[:length], n[:velocity] 
    end
    
  #### Key
  end

#### Zgomot::Comp 
end
