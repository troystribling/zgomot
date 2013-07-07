module Zgomot::Comp

  class Scale

    attr_reader :intervals, :shift, :scale

    def initialize(int, shift)
      @intervals = int
      @shift = shift - 1
      @scale = int.clone
      self.shift.times{self.next}
    end

    def next
      scale.push(scale.shift)
    end

    def method_missing(method, *args, &blk )
      scale.send(method, *args, &blk)
    end

  end
end
