##############################################################################################################
module Zgomot::Midi

  #####-------------------------------------------------------------------------------------------------------
  class Channel

    #.........................................................................................................
    include Zgomot::Comp::Transforms
    
    #.........................................................................................................
    @channels = []
    
    #####-------------------------------------------------------------------------------------------------------
    class << self
      
      #.........................................................................................................
      attr_reader :channels

      #.........................................................................................................
      def ch(num=0, opts={})
        (channels << new(is_valid(num), opts)).last
      end

      #.........................................................................................................
      def is_valid(num)
        nums = [num].flatten
        valid = nums.select{|n| 0 <= n and n <= 15 }
        valid.length.eql?(nums.length) ? num : raise(Zgomot::Error, "channel number invalid: 1<= channel <= 16")
      end

      #.........................................................................................................
      def release(chan)
        channels.delete_if{|c| c.eql?(chan)}
      end

    #### self
    end
    
    #####-------------------------------------------------------------------------------------------------------
    attr_reader :number, :clock, :notes
    attr_accessor :offset_time
    
    #.........................................................................................................
    def initialize(num, opts={})
      @offset_time = opts[:offset_time] || 0.0
      @number = num
      @clock = Clock.new
      @notes = []
    end

    #.........................................................................................................
    def <<(item)
      add_at_time(item); self
    end

    #.........................................................................................................
    def +(items)
      raise(Zgomot::Error, "must be Array") unless items.kind_of?(Array)
      items.each {|n| add_at_time(n)}; self
    end

    #.........................................................................................................
    def method_missing(method, *args, &blk )
      return @notes.send(method, *args, &blk)
    end

    #.........................................................................................................
    def to_sec
      clock.current_time.to_f
    end

  private
  
    #.........................................................................................................
    def add_at_time(item)
      items = [item].flatten
      items.flatten.each do |n|
        raise(Zgomot::Error, "must be Zgomot::Midi::Note") unless n.kind_of?(Zgomot::Midi::Note)  
        unless n.pitch_class.eql?(:R)    
          n.time = clock.current_time
          n.channel = number
          @notes << n
        end
      end  
      clock.update(items.first.length_to_sec)
    end
  
  #### Channel
  end

#### Zgomot::Midi 
end
