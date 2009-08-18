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
      def str(name, pattern, opts={}, &blk)
        strm = new(pattern)
        raise ArgumentError 'str block arity must be 2' unless blk.arity.eql?(2)
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
    attr_reader :patterns, :times, :status
    
    #.........................................................................................................
    def initialize(pattern)
      @patterns = [pattern]
      @times = [Time.new]
      @status = :playing
    end

    #.........................................................................................................
    def dispatch(time)       
      if (chan = play(times.first, patterns.first)).kind_of?(Zgomot::Midi::Channel)      
        Dispatcher.enqueue(chan.time_shift(time))
      end
    end

  #### Stream
  end

#### Zgomot::Midi 
end
