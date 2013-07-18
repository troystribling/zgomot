module Zgomot::Comp
  class Pattern
    class << self
      def n(p=[:C,4], opts = {})
        l = opts[:l] || 4; v = opts[:v] || 0.6
        Zgomot::Midi::Note.new(:pitch => p, :length => l, :velocity => v)
      end

      def c(tonic, chord = :maj, opts = {})
        l = opts[:l] || 4; v = opts[:v] || 0.6
        Chord.new(:tonic => tonic, :chord => chord, :length => l, :velocity => v)
      end

      def np(tonic=[:C,4], mode=0, opts = {})
        l = opts[:l] || 4; v = opts[:v] || 0.6
        Progression.new(:item => Note::Progression.new, :tonic => tonic, :mode => mode, :length => l, :velocity => v)
      end

      def cp(tonic=[:C,4], mode=0, opts = {})
        l = opts[:l] || 4; v = opts[:v] || 0.6
        Progression.new(:item => Chord::Progression.new(:scale), :tonic => tonic, :mode => mode, :length => l, :velocity => v)
      end

      def pr(percs = acoustic_bass_drum, opts = {})
        l = opts[:l] || 4; v = opts[:v] || 0.6
        Perc.new(:percs => percs, :length => l, :velocity => v)
      end
    end
    attr_reader :seq
    def initialize(seq)
      @seq = [seq].flatten
    end
    def method_missing(meth, *args, &blk)
      @seq = seq.map do |p|
               p.respond_to?(meth) ? p.send(meth, *args, &blk) : p
             end
      self
    end
  end
end
