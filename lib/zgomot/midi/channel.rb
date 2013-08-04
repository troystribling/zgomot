module Zgomot::Midi

  class Channel

    @channels = []

    class << self

      attr_reader :channels

      def ch(num=0)
        (channels << new(is_valid(num))).last
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

    attr_reader :number, :clock, :pattern, :length_to_sec, :offset

    def initialize(num)
      @number, @pattern, @offset = num, [], nil
      set_clock
    end

    def <<(pat)
      @pattern.clear
      @length_to_sec = 0.0
      pat = Zgomot::Comp::Pattern.new(pat) unless pat.kind_of?(Zgomot::Comp::Pattern)
      pat.seq.each do |p|
        p.time = clock.current_time
        p_sec = p.length_to_sec
        p.channel = number
        @length_to_sec += p_sec
        clock.update(p_sec)
        @pattern << Marshal.load(Marshal.dump(p))
      end; self
    end

    def method_missing(meth, *args, &blk )
      pattern.send(meth, *args, &blk); reset_pattern_time;self
    end

    def set_clock
      @offset, @clock = nil, Clock.new
    end

    def offset=(time)
      @offset ||= time
      pattern.each{|p| p.offset = offset}; self
    end

  end

end
