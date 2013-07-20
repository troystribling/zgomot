module Zgomot
  module Delegator
    class << self
      def delegate(del, *methods)
        methods.each do |method_name|
          class_eval <<-RUBY
            def #{method_name.to_s}(*args, &blk)
              ::#{del}.send(#{method_name.inspect}, *args, &blk)
            end
          RUBY
        end
      end
    end
    delegate Zgomot::Boot, :before_start
    delegate Zgomot::Midi::Stream, :str, :play, :streams, :lstr, :pause
    delegate Zgomot::Midi::Channel, :ch
    delegate Zgomot::Midi::Dispatcher, :clock
    delegate Zgomot::Midi::CC, :cc, :add_cc, :learn_cc, :lcc
    delegate Zgomot::Comp::Pattern, :np, :cp, :c, :n, :pr
    delegate Zgomot::Comp::Markov, :mark
    delegate Zgomot::Drivers::Mgr, :sources, :destinations, :input, :output,
             :add_input, :remove_input
    delegate Zgomot::UI::Window, :dash
  end
end

include Zgomot::Delegator

at_exit do
  unless Zgomot.live
    Zgomot::Boot.boot
    Zgomot::Midi::Stream.streams.each{|s| s.thread.join}
    loop do
      break if Zgomot::Midi::Dispatcher.done?
      sleep(Zgomot::DISPATCHER_POLL)
    end
  end
  Zgomot.logger.info "ZGOMOT IS FINISHED"
end
