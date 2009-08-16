##############################################################################################################
module Zgomot::Midi

  #####-------------------------------------------------------------------------------------------------------
  class Time

    #.........................................................................................................
    attr_reader :measure, :beat, :tick, :seconds
  
    #.........................................................................................................
    def initialize(arg=nil)
      if arg.kind_of?(Hash)
        [:measure, :beat, :tick].each{|a| raise ArgumentError "#{a} is a required argument" unless args.include?(a)}
        init_with_measure_beat_tick(arg) 
      elsif arg.nil?; init_with_nil     
      elsif arg.kind_of?(Float); init_with_seconds(arg); end
    end

    #.........................................................................................................
    def to_s
      "#{measure}.#{note}.#{tick}"
    end

    #.........................................................................................................
    def to_f
      seconds
    end
    
  private
  
    #.........................................................................................................
    def init_with_seconds(sec)
      @seconds = sec
      @measure = (sec/Clock.measure_sec).to_i
      @beat = ((sec % Clock.measure_sec)/Clock.beat_sec).to_i
      @tick = ((sec - measure*Clock.measure_sec - beat*Clock.beat_sec)/Clock.tick_sec).to_i
    end

    #.........................................................................................................
    def init_with_measure_beat_tick(args)
      @measure, @beat, @tick = args[:measure], args[:beat], args[:tick]
      @seconds = (measure*Clock.measure_sec + beat*Clock.beat_sec + tick*Clock.tick_sec).to_f
    end

    #.........................................................................................................
    def init_with_nil
      @measure, @beat, @tick, @seconds = 0, 0, 0, 0.0
    end
    
  #### Time
  end

  #####-------------------------------------------------------------------------------------------------------
  class Clock

    #.........................................................................................................
    @beats_per_measure, @beat_note = Zgomot.config[:time_signature].split('/').map{|v| v.to_f}
    @beats_per_minute = Zgomot.config[:beats_per_minute].to_f
    @resolution = Zgomot.config[:resolution].split('/').last.to_f
    @beat_sec= 60.0/@beats_per_minute
    @whole_note_sec = @beat_sec*@beat_note
    @measure_sec = @beat_sec*@beats_per_measure
    @tick_sec = @whole_note_sec/(4*@resolution)

    #####-------------------------------------------------------------------------------------------------------
    class << self

      #.........................................................................................................
      attr_reader :beat_note, :beats_per_measure, :beats_per_minute, :resolution, 
                  :beat_sec, :whole_note_sec, :measure_sec, :tick_sec
          
    #### self
    end
    
    #####-------------------------------------------------------------------------------------------------------
    attr_reader :current_time
    
    #...........................................................................................................
    def initialize
      @current_time = Time.new
    end

    #...........................................................................................................
    def update(time)
      csecs = if time.kind_of?(Float)
                current_time.to_f + time
              elsif time.kind_of?(Zgomot::Midi::Time)
                current_time.to_f + time.to_f
              else
                raise ArgumentError "argument must by of type Float or Zgomot::Midi::Time" 
              end
      @current_time = Time.new(csecs)
    end

  #### Clock
  end

#### Zgomot ::Midi
end
