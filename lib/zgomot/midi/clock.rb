module Zgomot::Midi

  class Time

    attr_reader :measure, :beat, :tick, :seconds

    def initialize(args=nil)
      if args.kind_of?(Hash)
        [:measure, :beat, :tick].each{|a| raise(Zgomot::Error, "#{a} is a required argument") unless args.include?(a)}
        init_with_measure_beat_tick(args)
      elsif args.nil?; init_with_nil
      elsif args.kind_of?(Float); init_with_seconds(args); end
    end
    def to_s
      "%d:%d:%d" % [measure, beat, tick]
    end
    def to_f
      seconds
    end
    def +(add_time)
      add_sec = if add_time.kind_of?(Float)
                  add_time
                elsif add_time.kind_of?(Zgomot::Midi::Time)
                  add_time.to_f
                else
                  raise(Zgomot::Error, "#{add_time.class.name} is invalid. Must be Float or Zgomot::Midi::Time")
                end
      self.class.new(seconds+add_sec)
    end
  private
    def init_with_seconds(sec)
      @seconds = sec
      @measure = (sec/Clock.measure_sec).to_i
      @beat = ((sec % Clock.measure_sec)/Clock.beat_sec).to_i
      @tick = ((sec - measure*Clock.measure_sec - beat*Clock.beat_sec)/Clock.tick_sec).to_i
    end
    def init_with_measure_beat_tick(args)
      @measure, @beat, @tick = args[:measure], args[:beat], args[:tick]
      @seconds = (measure*Clock.measure_sec + beat*Clock.beat_sec + tick*Clock.tick_sec).to_f
    end
    def init_with_nil
      @measure, @beat, @tick, @seconds = 0, 0, 0, 0.0
    end
  end

  class Clock
    class << self
      attr_accessor :beat_note, :beats_per_measure, :beats_per_minute, :resolution,
                    :beat_sec, :whole_note_sec, :measure_sec, :tick_sec, :time_signature,
                    :ticks_per_beat
      def set_config(config)
        @time_signature = config[:time_signature] || '4/4'
        @beats_per_minute = (config[:beats_per_minute] || '120').to_f
        @resolution = (config[:resolution] || '1/32').split('/').last.to_f
        @beats_per_measure, @beat_note = @time_signature.split('/').map{|v| v.to_f}
        @ticks_per_beat = @resolution/@beats_per_measure
        @beat_sec= 60.0/@beats_per_minute
        @whole_note_sec = @beat_sec*@beat_note
        @measure_sec = @beat_sec*@beats_per_measure
        @tick_sec = @whole_note_sec/(@resolution);nil
      end
    end
    set_config(Zgomot.config)
    attr_reader :current_time, :created_at
    def initialize
      @current_time, @created_at = Time.new, ::Time.now
    end
    def to_s
      @current_time.to_s
    end
    def +(add_clock)
      @current_time + if add_clock.knd_of(Float) or add_time.kind_of?(Zgomot::Midi::Time)
                        add_clock
                      elsif add_time.kind_of?(Zgomot::Midi::Clock)
                        add_clock.current_time
                      else
                        raise(Zgomot::Error, "#{add_clock.class.name} is invalid. Must be Float, Zgomot::Midi::Time or Zgomot::Midi::Clock")
                      end
    end
    def absolute_sec
      @current_time + created_at
    end
    def ceil
      Time.new(:measure => @current_time.measure + 1,
               :beat    => 0,
               :tick    => 0)
    end
    def update(time=nil)
      csecs = if time.kind_of?(Float)
                current_time.to_f + time
              elsif time.kind_of?(Zgomot::Midi::Time)
                current_time.to_f + time.to_f
              elsif time.nil?
                current_time.to_f + Clock.tick_sec
              else
                raise(Zgomot::Error, "argument must by of type Float or Zgomot::Midi::Time")
              end
      @current_time = Time.new(csecs)
    end

  end

end
