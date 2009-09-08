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
      attr_reader :chord_intervals

    #### self
    end
        
    #.........................................................................................................
    attr_reader :tonic, :length, :velocity, :chord, :clock, :intervals, :inversion, :time, :arp
    attr_accessor :offset_time, :channel
  
    #.........................................................................................................
    def initialize(args)
      @offset_time = args[:offset_time] || 0.0
      @channel, @time = args[:channel], args[:time]
      @length, @velocity, @chord = args[:length], args[:velocity], args[:chord]
      (@intervals =  Chord.chord_intervals[chord]) || raise(Zgomot::Error, "#{chord.inspect} is invalid")                      
      @tonic = case args[:tonic]
                when Array then args[:tonic]
                when Symbol then [args[:tonic], 4]
                when nil then [:C,4]
                else raise(Zgomot::Error, "#{args[:tonic].inspect} is invalid tonic")
              end
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
    def arp!(a)
      @notes = nil; @arp = a; self
    end
    
    #.........................................................................................................
    def notes
      @notes ||= pitches.map do |p| 
                   Zgomot::Midi::Note.new(:pitch => p, :length => length, :velocity => velocity, :time => time, 
                                          :offset_time => offset_time, :channel => channel)
                 end                          
    end
  
    #.........................................................................................................
    # channel and dispatch interface
    #.........................................................................................................
    def length_to_sec
      Zgomot::Midi::Clock.whole_note_sec*(1.0/length + (arp.nil? ? 0.0 : intervals.length.to_f/arp.to_f))
    end

    #.........................................................................................................
    def to_midi
      notes.map{|n| n.to_midi}
    end

    #.........................................................................................................
    def time=(t)
      @clock = Zgomot::Midi::Clock.new
      clock.update(t); @time = clock.current_time
      if arp
        notes.each do |n|
          n.time = clock.current_time
          clock.update(Zgomot::Midi::Clock.whole_note_sec/arp)
        end
      end
    end

    #.........................................................................................................
    def sum(a)
      a.inject(0) {|s,n| s+n}
    end

    #.........................................................................................................
    private :sum
      
  #### Chord
  end

#### Zgomot::Comp 
end
