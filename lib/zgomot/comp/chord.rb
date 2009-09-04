##############################################################################################################
module Zgomot::Comp

  #####-------------------------------------------------------------------------------------------------------
  class Chord

    #####-------------------------------------------------------------------------------------------------------
    # progession interface
    #####-------------------------------------------------------------------------------------------------------
    class Progression
    
      #.........................................................................................................
      attr_reader :chord

      #.........................................................................................................
      def initialize(chord)
        @chord = chord || :scale
      end
      
      #.........................................................................................................
      def notes(prog)
        chords = prog.mode.chords(chord)
        prog.items.select do |d| 
          chords[d-1]
        end.map do |d|
          Chord.new(:tonic => prog.pitches[d-1], :chord => chords[d-1], :length => prog.length, :velocity => prog.velocity, 
                    :time => prog.time, :offset_time => prog.offset_time, :channel => prog.channel)
        end
      end
    
    #### Progression  
    end

    #.........................................................................................................
    @all_intervals = {
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
      attr_reader :all_intervals

    #### self
    end
        
    #.........................................................................................................
    attr_reader :tonic, :length, :velocity, :chord, :intervals, :inversion
    attr_accessor :offset_time, :channel, :time
  
    #.........................................................................................................
    def initialize(c)
      @offset_time = c[:offset_time] || 0.0
      @channel, @time = c[:channel], c[:time]
      @length, @velocity, @chord = c[:length], c[:velocity], c[:chord]
      @tonic = case c[:tonic]
                when Array then c[:tonic]
                when Symbol then [c[:tonic], 4]
                else raise(Zgomot::Error, "#{c[:tonic].inspect} is invalid")
              end
      (@intervals =  Chord.all_intervals[chord]) || raise(Zgomot::Error, "#{chord.inspect} is invalid")                      
    end

    #.........................................................................................................
    def pitches
      last_pitch, octave = tonic; pitches = [tonic]
      intervals.each_index{|i| pitches << PitchClass.next(tonic.first, intervals[i])}
      pitches[1..-1].map do |p|
        octave += 1 if p < last_pitch; last_pitch = p.value; [last_pitch, octave]
      end.unshift(tonic)
    end

    #.........................................................................................................
    # channel and dispatch interface
    #.........................................................................................................
    def length_to_sec
      Zgomot::Midi::Clock.whole_note_sec/length
    end

    #.........................................................................................................
    def to_midi
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
