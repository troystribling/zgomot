##############################################################################################################
module Zgomot::Midi

  #####-------------------------------------------------------------------------------------------------------
  class Dispatcher

    #.........................................................................................................
    @queue, @playing = [], []
    @qmutex, @qdispatch = Mutex.new, Mutex.new
    
    #.........................................................................................................
    @clock = Clock.new
    @tick = Clock.tick_sec

    #####-------------------------------------------------------------------------------------------------------
    class << self
      
      #.........................................................................................................
      attr_reader :resolution, :queue, :thread, :clock, :tick, :qmutex, :qdispatch, :playing, :last_time

      #.........................................................................................................
      def flush
        @queue.clear
      end
      #.........................................................................................................
      def done?
        qdispatch.synchronize{queue.empty? and playing.empty?}
      end

      #.........................................................................................................
      def enqueue(ch)        
        qmutex.synchronize do
          @queue += ch.pattern.map{|p| p.to_midi}.flatten.compact.select{|n| not n.pitch_class.eql?(:R)}
        end
      end
        
      #.........................................................................................................
      def dequeue(time)
        qmutex.synchronize do
          queue.partition{|n| n.play_at <= time}
        end
      end

      #.........................................................................................................
      def dispatch(now)
        qdispatch.synchronize do 
          ready, @queue = dequeue(now)
          notes_off(now)
          notes_on(ready)
        end
      end

      #.........................................................................................................
      def notes_on(notes)
        notes.each do |n| 
          Zgomot.logger.info "NOTE ON: #{n.channel} : #{n.to_s} : #{n.time.to_s} : #{clock.current_time.to_s}"
          Zgomot::Drivers::Mgr.note_on(n.midi, n.channel, (127*n.velocity).to_i)
        end
        @playing += notes
      end

      #.........................................................................................................
      def notes_off(time)
        turn_off, @playing = playing.partition{|n| (n.play_at+n.length_to_sec) <= time}
        turn_off.each do |n| 
          Zgomot.logger.info "NOTE OFF:#{n.channel} : #{n.to_s} : #{n.time.to_s} : #{clock.current_time.to_s}"
          Zgomot::Drivers::Mgr.note_off(n.midi, n.channel, (127*n.velocity).to_i)
        end
      end

      #.........................................................................................................
      private :dispatch, :notes_on, :notes_off

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
