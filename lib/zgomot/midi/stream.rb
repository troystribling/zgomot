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
      def str(name, pattern=nil, opts={}, &blk)
        strm = new(name, blk.arity, pattern, opts[:limit])
        strm.define_meta_class_method(:play, &blk) 
        @streams << strm
      end

      #.........................................................................................................
      def play 
        streams.each{|s| s.dispatch(::Time.now.to_f + Zgomot::PLAY_DELAY)}
      end
      
    #### self
    end
    
    #####-------------------------------------------------------------------------------------------------------
    attr_reader :patterns, :times, :status, :count, :thread, :limit, :name, :play_meth
    
    #.........................................................................................................
    def initialize(name, arity, pattern, limit)
      @patterns, @times = [pattern], [Time.new]
      @limit, @name, @count, @thread, @status = limit || 1, name, 0, nil, :playing
      @play_meth = "play#{arity.eql?(-1) ? 0 : arity}".to_sym
    end

    #.........................................................................................................
    def dispatch(start_time)  
      ch_time = 0.0  
      @thread = Thread.new do
                  loop do
                    @count += 1
                    if self.respond_to?(play_meth, true)  
                      if (chan = self.send(play_meth)).kind_of?(Zgomot::Midi::Channel)  
                       Dispatcher.enqueue(chan.time_shift(start_time+ch_time))
                      else; break; end
                    else
                      raise(Zgomot::Error, 'str block arity not supported')
                    end
                    Zgomot.logger.info "STREAM:#{name}:#{count}"
                    break if not limit.eql?(:inf) and count.eql?(limit)
                    ch_time += chan.to_sec; patterns << chan.notes; times << Time.new(ch_time)
                    sleep(0.90*(start_time+ch_time-::Time.now.to_f))
                  end
        Zgomot.logger.info "STREAM:#{name}:finished"
        @status = :finished          
      end         
    end

  private
  
    #.........................................................................................................
    def play0;play;end
    def play2;play(times.last, Marshal.load(Marshal.dump(patterns.last)));end
    
  #### Stream
  end

#### Zgomot::Midi 
end
