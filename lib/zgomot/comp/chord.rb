##############################################################################################################
module Zgomot::Comp

  #####-------------------------------------------------------------------------------------------------------
  class Chord

    #.........................................................................................................
    @chord_intervals = {
      :maj  => [4,7],
      :min  => [3,7],
      :dim  => [3,6],
      :aug  => [4,8],
      :sus2 => [2,7],
      :sus4 => [5,7]
      }
    
    #####-------------------------------------------------------------------------------------------------------
    class << self
    
      #.........................................................................................................
      attr_reader :chords
    
    #### self  
    end
    
    #####-------------------------------------------------------------------------------------------------------
    attr_reader :pitch_class, :octave, :length, :velocity, :time, :chord, :interval, :inversion
    attr_accessor :offset_time, :channel
  
    #.........................................................................................................
    def initialize(c)
      @offset_time = n[:offset_time] || 0.0
      @channel, @time = n[:channel], n[:time]
      @length, @velocity, @chord = n[:length], n[:velocity], n[:chord]
      @pitch_class, @octave = case n[:root]
                                when Array then n[:root]
                                when Symbol then [n[:root], 4]
                                else raise(Zgomot::Error, "#{n[:root].inspect} is invalid")
                              end
      (@interval =  chord_intervals[chord]) || raise(Zgomot::Error, "#{chord.inspect} is invalid")                      
    end

    #.........................................................................................................
    def pitches
      last_pitch = pitch_class; pitch = [last_pitch]
      interval.each_index{|i| pitch << PitchClass.next(pitch_class.first, sum(interval[0..i]))}
      pitch[1..-1].map do |p|
        octave += 1 if p < last_pitch; last_pitch = p.value; [last_pitch, octave]
      end
    end

    #.........................................................................................................
    # channel and dispatch interface
    def length_to_sec
      Clock.whole_note_sec/length
    end

    #.........................................................................................................
    def to_notes
      pitches.map do |p| 
        Zgomot::Midi::Note.new(:pitch => p, :length => length, :velocity => velocity, :time => time, 
                               :offset_time => offset_time, :channel => channel)
      end
    end

  private

    #.........................................................................................................
    def sum(a)
      a.inject(0) {|s,n| s+n}
    end
      
  #### Chord
  end

#### Zgomot::Comp 
end
