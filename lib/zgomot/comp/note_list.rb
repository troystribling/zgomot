module Zgomot::Comp

  class NoteList

    def self.nl(*args)
      NoteList.new(*args)
    end

    extend Forwardable
    def_delegators :notes, :reverse!, :shift, :pop, :push, :unshift

    attr_reader :notes, :clock

    def initialize(*notes)
      unless notes.all?{|n| n.class == Zgomot::Midi::Note or n.class == Zgomot::Comp::Perc}
        raise(Zgomot::Error, "all arguments must be class Zgomot::Midi::Note Zgomot::Comp::Perc")
      end
      @notes = notes
    end
    def <<(note)
      notes << note
    end
    def length_to_sec
      notes.map(&:length_to_sec).max
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
    def velocity=(v)
      notes.each{|n| n.velocity = v}; self
    end
    def length=(v)
      notes.each{|n| n.length = v}; self
    end
    def bpm!(bpm)
      notes.each{|n| n.bpm!(bpm)}; self
    end
    def octave!(oct)
      notes.each{|n| n.octave!(oct)}; self
    end
    def time=(time)
      @clock = Zgomot::Midi::Clock.new
      clock.update(time)
      notes.each{|n| n.time = clock.current_time}
    end

  end

end

