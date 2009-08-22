##############################################################################################################
module Zgomot::Midi

  #####-------------------------------------------------------------------------------------------------------
  class Dispatcher

    #.........................................................................................................
    @queue = []
    @playing = []
    @qmutex = Mutex.new
    
    #.........................................................................................................
    @clock = Clock.new
    @tick = Clock.tick_sec

    #####-------------------------------------------------------------------------------------------------------
    class << self
      
      #.........................................................................................................
      attr_reader :resolution, :queue, :thread, :clock, :tick, :qmutex, :playing, :last_time

      #.........................................................................................................
      def flush
        @queue.clear
      end

      #.........................................................................................................
      def enqueue(ch)        
        qmutex.synchronize do
          @queue += ch.notes.flatten.compact.select{|n| not n.pitch_class.eql?(:R)}.map{|n| n.to_notes}
        end
      end
        
      #.........................................................................................................
      def dequeue(time)
        qmutex.synchronize do
          queue.partition{|n| n.play_at <= time}
        end
      end

    private

      #.........................................................................................................
      def dispatch(now)
        ready, @queue = dequeue(now)
        notes_on(ready)
        notes_off(now)
      end

      #.........................................................................................................
      def notes_on(notes)
        notes.each do |n| 
          Zgomot.logger.info "NOTE ON: #{n.to_s}:#{n.time.to_s}:#{clock.current_time.to_s}"
         Interface.driver.note_on(n.midi, n.channel, n.velocity)
        end
        @playing += notes
      end

      #.........................................................................................................
      def notes_off(time)
        turn_off, @playing = playing.partition{|n| (n.play_at+n.length_to_sec) <= time}
        turn_off.each do |n| 
          Zgomot.logger.info "NOTE OFF:#{n.to_s}:#{n.time.to_s}:#{clock.current_time.to_s}"
          Interface.driver.note_off(n.midi, n.channel, n.velocity)
        end
      end

    #### self
    end

    #.........................................................................................................
    @thread = Thread.new do
      loop do
        now = ::Time.now.truncate_to(Clock.tick_sec)
        dispatch(now)       
        clock.update(last_time.nil? ? tick : now-last_time)
        @last_time = now
        sleep(tick)
      end
    end

  #### Dispatcher
  end

#### Zgomot::Midi 
end
