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
          streams.reduce([]) do |a, s|
            if s.status_eql?(:paused)
              s.dispatch(start_time + s.delay)
              a << s.name
            end; a
          end
        else
          apply_to_stream(name){|stream|
            stream.status_eql?(:paused) ? (stream.dispatch(start_time + stream.delay); name) : nil}
        end
      end
      alias_method :run, :play
      def pause(name=nil)
        if name.nil?
          streams.each do |stream|
            stream.update_status(:paused)
          end; true
        else
          apply_to_stream(name) do |stream|
            stream.update_status(:paused)
            name
          end
        end
      end
      alias_method :stop, :pause
      def tog(name)
        apply_to_stream(name) do |stream|
          stream.status_eql?(:playing) ? pause(name) : play(name)
        end
      end
      def apply_to_stream(name)
        stream = streams.find{|s| s.name == name.to_s}
        if stream
          yield stream
        else
          Zgomot.logger.error "STREAM '#{name}' NOT FOUND"; nil
        end
      end
    end

    attr_accessor :count
    attr_reader :patterns, :status, :thread, :limit, :name, :play_meth,
                :delay, :ch

    def initialize(name, arity, pattern, opts)
      @patterns = [Zgomot::Comp::Pattern.new(pattern)]
      @delay = (opts[:del].to_f * 60.0/ Zgomot.config[:beats_per_minute].to_f).to_i || 0
      @limit, @name, @thread, @status, @count = opts[:lim] || :inf, name, nil, :paused, 0
      @ch = Zgomot::Midi::Channel.ch(opts[:ch] || 0)
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
    def info
      [name, status, ch.number, count, limit, delay].map(&:to_s)
    end
    def dispatch(start_time)
      @count = 0
      ch.set_clock
      update_status(:playing)
      @thread = Thread.new do
                  while(status_eql?(:playing)) do
                    @count += 1
                    loop_time = ::Time.now
                    break if not limit.eql?(:inf) and count > limit
                    if self.respond_to?(play_meth, true)
                      if pattern = self.send(play_meth)
                        ch << pattern
                        Dispatcher.enqueue(ch.time_shift(start_time))
                      else; break; end
                    else
                      raise(Zgomot::Error, 'str block arity not supported')
                    end
                    Zgomot.logger.info "STREAM:#{count}:#{name}"
                    patterns << Zgomot::Comp::Pattern.new(ch.pattern)
                    sleep(ch.length_to_sec) if count > 1
                  end
        Zgomot.logger.info "STREAM FINISHED:#{name}"
        update_status(:paused)
      end
    end

    def play0;play;end
    def play1;play(Marshal.load(Marshal.dump(patterns.last)));end

    private :play0, :play1

  end

end
