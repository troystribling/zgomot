module Zgomot::Comp
  class PitchClass
    PITCH_CLASS = {
      :C  => 0,
      :Cs => 1,
      :D  => 2,
      :Ds => 3,
      :E  => 4,
      :F  => 5,
      :Fs => 6,
      :G  => 7,
      :Gs => 8,
      :A  => 9,
      :As => 10,
      :B  => 11
    }
    class << self
      def next(pc, interval)
        start_pos = PITCH_CLASS[to_value(pc)]
        new(PITCH_CLASS.inject([]){|r,(c,p)|  p.eql?((start_pos+interval) % 12) ? r << c : r}.first) if start_pos
      end
      def to_value(p)
        p.kind_of?(PitchClass) ? p.value : p
      end
    end
    attr_reader :value
    def initialize(p)
      raise(Zgomot::Error, "#{p} is invalid pitch class") unless PITCH_CLASS.include?(p)
      @value = p
    end
    def <(p)
      PITCH_CLASS[value] < PITCH_CLASS[self.class.to_value(p)]
    end
    def >(p)
      PITCH_CLASS[value] > PITCH_CLASS[self.class.to_value(p)]
    end
  end
end
