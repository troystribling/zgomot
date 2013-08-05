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
    delegate Zgomot::Midi::Clock, :set_config
    delegate Zgomot::Midi::Stream, :str, :run, :play, :pause, :stop, :tog
    delegate Zgomot::Midi::Dispatcher, :clk
    delegate Zgomot::Midi::CC, :cc, :add_cc, :learn_cc
    delegate Zgomot::Comp::Pattern, :np, :cp, :c, :n, :pr
    delegate Zgomot::Comp::Markov, :mark
    delegate Zgomot::Drivers::Mgr, :sources, :destinations, :input, :output,
             :add_input, :remove_input
    delegate Zgomot::UI::MainWindow, :dash
    delegate Zgomot::UI::Output, :lstr, :lcc, :lconfig
    delegate Zgomot, :watch
  end

  def self.watch(dir=nil)
    dir ||= '.'
    Zgomot.logger.info "WATCHING '#{dir}' FOR UPDATES"
    Thread.new do
      FSSM.monitor(dir) do
        update do |dir, file|
          playing_streams = Zgomot::Midi::Streams.streams.select{|s| s.status == :playing}
          playing_streams.each{|s| Zgomot::Midi::Streams.pause(s.name)}
          while(Zgomot::Midi::Streams.streams.any{|s| s.status_eql?(:playing)}) do
            sleep(Zgomot::Midi::Clock.measure_sec)
          end
          path = File.join(dir, file)
          Zgomot.logger.info "LOADED UPDATED FILE: #{path}"
          load path
          playing_streams.each{|s| Zgomot::Midi::Streams.play(s.name)}
        end
        create do |dir, file|
          path = File.join(dir, file)
          Zgomot.logger.info "LOADED CREATED FILE: #{path}"
          load path
        end
      end
    end
    dir
  end
end

include Zgomot::Delegator

at_exit do
  unless Zgomot.live
    Zgomot::Boot.boot
    Zgomot::Midi::Stream.streams.values.each{|s| s.thread.join unless s.thread.nil?}
    loop do
      break if Zgomot::Midi::Dispatcher.done?
      sleep(Zgomot::DISPATCHER_POLL)
    end
  end
  Zgomot.logger.info "ZGOMOT IS FINISHED"
end
