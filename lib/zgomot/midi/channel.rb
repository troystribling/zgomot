module Zgomot::Midi

  class Channel

    @channels = []

    class << self

      attr_reader :channels

      def ch(num=0, opts={})
        (channels << new(is_valid(num), opts)).last
      end

      def is_valid(num)
        nums = [num].flatten
        valid = nums.select{|n| 0 <= n and n <= 15}
        valid.length.eql?(nums.length) ? num : raise(Zgomot::Error, "channel number invalid: 1<= channel <= 16")
      end

      def release(chan)
        channels.delete_if{|c| c.eql?(chan)}
      end

    end

    attr_reader :number, :clock, :pattern

    def initialize(num, opts={})
      @number = num
      @clock = Clock.new
      @pattern = []
    end

    def <<(pat)
      pat = Zgomot::Comp::Pattern.new(pat) unless pat.kind_of?(Zgomot::Comp::Pattern)
      pat.seq.each do |p|
        p.time = clock.current_time
        p.channel = number
        @pattern << Marshal.load(Marshal.dump(p))
        clock.update(p.length_to_sec)
      end; self
    end

    def method_missing(meth, *args, &blk )
      pattern.send(meth, *args, &blk); reset_pattern_time; self
    end

    def length_to_sec
      clock.current_time.to_f
    end

    def time_shift(secs)
      pattern.each{|p| p.offset_time=secs}; self
    end

    def reset_pattern_time
      @clock = Clock.new
      pattern.each do |pat|
        pat.time = clock.current_time
        clock.update(pat.length_to_sec)
      end
    end

    private :reset_pattern_time

  end

end
