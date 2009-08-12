##############################################################################################################
module Zgomot::Midi

  #####-------------------------------------------------------------------------------------------------------
  class Timer

    #.........................................................................................................
    attr_reader :resolution, :queue, :thread, :clock, :tick

    #.........................................................................................................
    def initialize
      @queue = []
      @clock = Clock.new
      @tick = Clock.tick_length
      @thread = Thread.new do
        loop do
          dispatch
          clock.update(tick)
          sleep(tick)
        end
      end
    end

    #.........................................................................................................
    def flush
      @queue.clear
    end

    #.........................................................................................................
    def at(time, &blk)
      time = time.to_f if time.kind_of? Time
      @queue.push [time, blk]
    end

  private

    #.........................................................................................................
    def dispatch
      now = Time.now.to_f
      ready, @queue = @queue.partition {|time, blk| time.to_f <= now.to_f}
      ready.each {|time, blk| blk[time]}
    end

  #### Timer
  end

#### Zgomot::Midi 
end
