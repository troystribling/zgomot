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
          Chord.new(:tonic => prog.pitches[d-1], :chord => chords[d-1], :length => prog.length, :velocity => prog.velocity)
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
    attr_reader :tonic, :length, :velocity, :chord, :clock, :intervals, :inversion, :arp, :time_scale
  
    #.........................................................................................................
    def initialize(args)
      @length, @velocity, @chord = args[:length], args[:velocity], args[:chord]
      (@intervals =  Chord.chord_intervals[chord]) || raise(Zgomot::Error, "#{chord.inspect} is invalid")                      
      @time_scale = 1.0
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
    def bpm_scale!(bpm)
      @time_scale = 1.0/bpm.to_f; self
    end
    
    #.........................................................................................................
    def notes
      @notes ||= pitches.map do |p| 
                   Zgomot::Midi::Note.new(:pitch => p, :length => length, :velocity => velocity)
                 end                          
    end
  
    #.........................................................................................................
    # channel and dispatch interface
    #.........................................................................................................
    def length_to_sec
      time_scale*Zgomot::Midi::Clock.whole_note_sec*(1.0/length + (arp.to_f.eql?(0.0) ? 0.0 : intervals.length.to_f/arp.to_f))
    end

    #.........................................................................................................
    def to_midi
      notes.map{|n| n.to_midi}
    end

    #.........................................................................................................
    def channel=(chan)
      notes.each{|n| n.channel = chan}
    end

    #.........................................................................................................
    def offset_time=(time)
      notes.each{|n| n.offset_time = time}
    end
    
    #.........................................................................................................
    def time=(t)
      @clock = Zgomot::Midi::Clock.new
      clock.update(t)
      notes.each do |n|
        n.time = clock.current_time
        clock.update(Zgomot::Midi::Clock.whole_note_sec/arp.to_f) if arp.to_f > 0.0        
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
