module Zgomot::Comp

  class Chord

    class Progression

      attr_reader :chord
      def initialize(chord)
        @chord = chord || :scale
      end
      def notes(prog)
        chords = prog.mode.chords(chord); count = -1
        prog.items.select do |d|
          d.eql?(:R) || chords[d-1]
        end.map do |d|
          count += 1; idx_length, idx_velocity = count % prog.length.length, count % prog.velocity.length
          unless d.eql?(:R)
            Chord.new(:tonic => prog.pitches[d-1], :chord => chords[d-1], :length => prog.length[idx_length], :velocity => prog.velocity[idx_velocity])
          else
            Zgomot::Midi::Note.new(:pitch => :R, :length => prog.length[idx_length], :velocity => prog.velocity[idx_velocity])
          end
        end
      end
    end

    @chord_intervals = {
      :maj  => [4,7],
      :min  => [3,7],
      :dim  => [3,6],
      :aug  => [4,8],
      :sus2 => [2,7],
      :sus4 => [5,7]
      }

    class << self
      attr_reader :chord_intervals
    end

    attr_reader :tonic, :chord, :clock, :intervals, :arp, :time_scale, :items, :inversion, :reverse,
                :length, :velocity

    def initialize(args)
      @length, @velocity, @chord = args[:length], args[:velocity], args[:chord]
      (@intervals =  Chord.chord_intervals[chord]) || raise(Zgomot::Error, "#{chord.inspect} is invalid")
      @time_scale, @inversion, @reverse = 1.0, 0, false
      @tonic = case args[:tonic]
                when Array then args[:tonic]
                when Symbol then [args[:tonic], 4]
                when nil then [:C,4]
                else raise(Zgomot::Error, "#{args[:tonic].inspect} is invalid tonic")
              end
    end

    def pitches
      last_pitch, octave = tonic; pitches = [tonic]
      intervals.each_index{|i| pitches << PitchClass.next(tonic.first, intervals[i])}
      nts = pitches[1..-1].map do |p|
              octave += 1 if p < last_pitch; last_pitch = p.value; [last_pitch, octave]
            end.unshift(tonic)
      @reverse ? invert(nts).reverse : invert(nts)
    end
    def note(number)
      Zgomot::Midi::Note.new(:pitch => pitches[number], :length => length, :velocity => velocity)
    end
    def notes
      @notes ||= pitches.map do |p|
                   Zgomot::Midi::Note.new(:pitch => p, :length => length, :velocity => velocity)
                 end
    end
    def arp!(v)
      @notes = nil; @arp = v; self
    end
    def inv!(v)
      @notes = nil; @inversion = v; self
    end
    def rev!
      @reverse = true; self
    end
    def bpm!(v)
      @time_scale = 1.0/v.to_f; self
    end
    def octave!(v)
      @notes = nil; @octave = v; self
    end
    def length=(v)
      @length = v; self
    end
    def valocity=(v)
      @length = v; self
    end
    def length_to_sec
      time_scale*Zgomot::Midi::Clock.whole_note_sec*(1.0/length + (arp.to_f.eql?(0.0) ? 0.0 : intervals.length.to_f/arp.to_f))
    end
    def to_midi
      notes.map{|n| n.to_midi}
    end
    def channel=(chan)
      notes.each{|n| n.channel = chan}
    end
    def offset=(time)
      notes.each{|n| n.offset = time}
    end
    def time=(time)
      @clock = Zgomot::Midi::Clock.new
      clock.update(time)
      notes.each do |n|
        n.time = clock.current_time
        clock.update(Zgomot::Midi::Clock.whole_note_sec/arp.to_f) if arp.to_f > 0.0
      end
    end
    def sum(a)
      a.inject(0) {|s,n| s+n}
    end
    def invert(p)
      inversion.times do |i|
        n = p.shift; p.push([n.first, (n.last.eql?(9) ? n.last : n.last+1)])
      end; p
    end
    private :sum, :invert

  end

end
