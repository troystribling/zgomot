module Zgomot::Midi

  class Stream

    @streams = []

    class << self
      attr_reader :streams
      def str(name, pattern=nil, opts={}, &blk)
        strm = new(name, blk.arity, pattern, opts)
        strm.define_meta_class_method(:play, &blk)
        @streams << strm
      end
      def play(name=nil)
        start_time = ::Time.now.truncate_to(Clock.tick_sec) + Zgomot::PLAY_DELAY
        if name.nil?
          streams.each{|s| s.dispatch(start_time + s.delay) if s.status == :new}
        else
          apply_to_stream(name){|stream| stream.dispatch(start_time + s.delay)} if stream.status != :playing
        end
      end
      def apply_to_stream(name)
        stream = streams.find{|s| s.name == name}
        if stream
          yield stream
        else
          Zgomot.logger.error "STREAM '#{name}' NOT FOUND"
        end
      end
      def pause(name)
        apply_to_stream(name){|stream| stream.update_status(:paused)}
      end
      def info(name=nil)
        if name.nil?
        else
        end
      end
      def lstr(name=nil)
      end
    end

    attr_reader :patterns, :times, :status, :count, :thread, :limit, :name, :play_meth, :delay

    def initialize(name, arity, pattern, opts)
      @patterns, @times = [Zgomot::Comp::Pattern.new(pattern)], [Time.new]
      @delay = (opts[:del].to_f * 60.0/ Zgomot.config[:beats_per_minute].to_f).to_i || 0
      @limit, @name, @count, @thread, @status = opts[:lim] || :inf, name, 0, nil, :new
      @play_meth = "play#{arity.eql?(-1) ? 0 : arity}".to_sym
      @status_mutex = Mutex.new
    end
    def update_status(new_status)
      @status_mutex.synchronize do
        @status = new_status
      end
    end
    def status_eql?(test_status)
      @status_mutex.synchronize do
        @status == test_status
      end
    end
    def dispatch(start_time)
      ch_time = 0.0
      update_status(:playing)
      @thread = Thread.new do
                  while(status_eql?(:playing)) do
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
                    ch_time += chan.length_to_sec
                    times << Time.new(ch_time)
                    sleep(0.80*(start_time+ch_time-::Time.now.truncate_to(Clock.tick_sec)))
                  end
        Zgomot.logger.info "STREAM FINISHED:#{name}"
        update_status(:finished)
      end
    end

    def play0;play;end
    def play1;play(Marshal.load(Marshal.dump(patterns.last)));end

    private :play0, :play1

  end

end
