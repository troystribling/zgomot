##############################################################################################################
module Zgomot::Comp

  #####-------------------------------------------------------------------------------------------------------
  class Chord
    
    #####-------------------------------------------------------------------------------------------------------
    attr_reader :pitches, :length, :velocity, :time
    attr_accessor :time, :offset_time, :channel
  
    #.........................................................................................................
    def initialize(c)
      @offset_time = n[:offset_time] || 0.0
      @channel, @time = n[:channel], n[:time]
      @length, @velocity = n[:length], n[:velocity] 
      @pitches = n[:pitches]
    end

    #.........................................................................................................
    def length_to_sec
      Clock.whole_note_sec/length
    end

    #.........................................................................................................
    def to_s
      "[#{pitch_class.to_s},#{octave}].#{length}.#{midi}.#{velocity}"
    end

    #.........................................................................................................
    def to_notes
      pitches.map do |p| 
        Zgomot::Midi::Note.new(:pitch => p, :length => length, :velocity => velocity, :time => time, 
                               :offset_time => offset_time, :channel => channel)
      end
    end
      
  #### Chord
  end

#### Zgomot::Comp 
end
