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
        strm = new(name, blk.arity, pattern, opts)
        strm.define_meta_class_method(:play, &blk) 
        @streams << strm
      end

      #.........................................................................................................
      def play 
        streams.each{|s| s.dispatch(::Time.now.truncate_to(Clock.tick_sec) + Zgomot::PLAY_DELAY + s.delay) if s.status.eql?(:new)}
      end
      
    #### self
    end
    
    #####-------------------------------------------------------------------------------------------------------
    attr_reader :patterns, :times, :status, :count, :thread, :limit, :name, :play_meth, :delay
    
    #.........................................................................................................
    def initialize(name, arity, pattern, opts)
      @patterns, @times = [Zgomot::Comp::Pattern.new(pattern)], [Time.new]
      @delay = (opts[:del].to_f * 60.0/ Zgomot.config[:beats_per_minute].to_f).to_i || 0
      @limit, @name, @count, @thread, @status = opts[:lim] || :inf, name, 0, nil, :new
      @play_meth = "play#{arity.eql?(-1) ? 0 : arity}".to_sym
    end

    #.........................................................................................................
    def dispatch(start_time)  
      ch_time, @status = 0.0, :playing 
      @thread = Thread.new do
                  loop do
                    @count += 1
                    break if not limit.eql?(:inf) and count > limit
                    if self.respond_to?(play_meth, true)  
                      if (chan = self.send(play_meth)).kind_of?(Zgomot::Midi::Channel) 
                        Dispatcher.enqueue(chan.time_shift(start_time+ch_time))
                      else; break; end
                    else
                      raise(Zgomot::Error, 'str block arity not supported')
                    end
                    Zgomot.logger.info "STREAM:#{count}:#{name}"
                    patterns << Zgomot::Comp::Pattern.new(chan.pattern)
                    ch_time += chan.length_to_sec; times << Time.new(ch_time)
                    sleep(0.80*(start_time+ch_time-::Time.now.truncate_to(Clock.tick_sec)))
                  end
        Zgomot.logger.info "STREAM FINISHED:#{name}"
        @status = :finished          
      end         
    end
  
    #.........................................................................................................
    def play0;play;end
    def play1;play(Marshal.load(Marshal.dump(patterns.last)));end

    #.........................................................................................................
    private :play0, :play1
    
  #### Stream
  end

#### Zgomot::Midi 
end
