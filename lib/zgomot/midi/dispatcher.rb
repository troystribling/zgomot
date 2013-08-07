module Zgomot::Midi

  class Dispatcher

    @queue, @playing = [], []
    @qmutex = Mutex.new

    @clock = Clock.new
    @tick = Clock.tick_sec

    class << self

      attr_reader :resolution, :queue, :thread, :clock, :tick, :qmutex, :qdispatch, :playing

      def clk
        clock.to_s
      end

      def flush
        @queue.clear
      end

      def done?
        qmutex.synchronize{queue.empty? and playing.empty?}
      end

      def enqueue(ch)
        ch.offset = clock.ceil
        qmutex.synchronize do
          pattern = ch.pattern.map{|p| p.to_midi}.flatten.compact.select{|n| not n.pitch_class.eql?(:R)}
          @queue += pattern
        end
      end

      def dequeue
        qmutex.synchronize do
          queue.partition{|n| n.note_on.to_f <= clock.current_time.to_f}
        end
      end

      private

        def dispatch
          ready, @queue = dequeue
          notes_off
          notes_on(ready)
        end

        def notes_on(notes)
          @playing += notes
          notes.each do |n|
            Zgomot.logger.info "NOTE ON: #{n.channel} : #{n.to_s} - #{n.time.to_s} - #{n.note_on.to_s} - #{clock.current_time.to_s}"
            Zgomot::Drivers::Mgr.note_on(n.midi, n.channel, (127*n.velocity).to_i)
          end
        end

        def notes_off
          turn_off, @playing = playing.partition{|n| n.note_off.to_f <= clock.current_time.to_f}
          turn_off.each do |n|
            Zgomot.logger.info "NOTE OFF:#{n.channel} : #{n.to_s} - #{n.time.to_s} - #{n.note_off.to_s} - #{clock.current_time.to_s}"
            Zgomot::Drivers::Mgr.note_off(n.midi, n.channel, (127*n.velocity).to_i)
          end
        end

    end

    @thread = Thread.new do
      loop do
        dispatch
        clock.update(tick)
        sleep(tick)
      end
    end

  end

end
