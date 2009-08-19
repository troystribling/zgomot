##############################################################################################################
module Zgomot::Midi

  #####-------------------------------------------------------------------------------------------------------
  class Stream

    #.........................................................................................................
    @streams = []

    #####-------------------------------------------------------------------------------------------------------
    class << self
      
      #.........................................................................................................
      attr_reader :streams

      #.........................................................................................................
      def str(name, pattern, limit=1, opts={}, &blk)
        strm = new(pattern, limit)
        raise(Zgomot::Error, 'str block arity must be 2') unless blk.arity.eql?(2)
        if opts[:infinite]
        else
          strm.define_meta_class_method(:play, &blk) 
        end           
        @streams << strm
      end

      #.........................................................................................................
      def play 
        streams.each{|s| s.dispatch(::Time.now.to_f + Zgomot::PLAY_DELAY)}
      end
      
    #### self
    end
    
    #####-------------------------------------------------------------------------------------------------------
    attr_reader :patterns, :times, :status, :count, :thread
    
    #.........................................................................................................
    def initialize(pattern, limit)
      @patterns = [pattern]
      @times = [Time.new]
      @status = :playing
      @limit = limit
      @count = 0
      @thread = nil
    end

    #.........................................................................................................
    def dispatch(offset)    
      Thread.new do
        loop do
          pattern, time = patterns.last, times.last
          @count += 1
          if (chan = play(time, pattern)).kind_of?(Zgomot::Midi::Channel)  
            Dispatcher.enqueue(chan.time_shift(offset))
          else; break; end
          break if not limit.eql?(:inf) and count.eql?(limit)
          csec = chan.to_sec
          offset += csec
          patterns << chan.notes
          times << Time.new(csec)
          delay 
          sleep(0.95*csec)
        end
      end         
    end

  #### Stream
  end

#### Zgomot::Midi 
end
