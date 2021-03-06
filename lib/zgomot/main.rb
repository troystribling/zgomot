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
    delegate Zgomot::Midi::Stream, :str, :run, :play, :pause, :stop, :tog, :delete
    delegate Zgomot::Midi::Dispatcher, :clk
    delegate Zgomot::Midi::CC, :cc, :add_cc, :learn_cc
    delegate Zgomot::Comp::Pattern, :np, :cp, :c, :n, :pr
    delegate Zgomot::Comp::Markov, :mark
    delegate Zgomot::Drivers::Mgr, :sources, :destinations, :input, :output,
             :add_input, :remove_input
    delegate Zgomot::UI::MainWindow, :dash
    delegate Zgomot::UI::Output, :lstr, :lcc, :lconfig
    delegate Zgomot, :watch
    delegate Zgomot::Comp::NoteList, :nl
  end

  def self.last_error
    @last_error
  end

  def self.set_last_error(error)
    @last_error = error
  end

  def self.watch(dir=nil)
    dir ||= '.'
    raise(Zgomot::Error, "Directory '#{dir}' does not exist") unless Dir.exists?(dir)
    Zgomot.logger.info "WATCHING '#{dir}' FOR UPDATES"
    Thread.new do
      FSSM.monitor(dir) do
        update do |dir, file|
          unless /.*\.rb$/.match(file).nil?
            Zgomot.set_last_error(nil)
            path = File.join(dir, file)
            Zgomot.logger.info "LOADED UPDATED FILE: #{path}"
            playing_streams = Zgomot::Midi::Stream.streams.values.select{|s| s.status_eql?(:playing)}
            playing_streams.each{|s| Zgomot::Midi::Stream.pause(s.name)}
            sleep(Zgomot::Midi::Clock.measure_sec)
            begin
              load path
            rescue Exception => e
              Zgomot.set_last_error(e.message)
            end
            playing_streams.each{|s| Zgomot::Midi::Stream.play(s.name)}
          end
        end
        create do |dir, file|
          unless /.*\.rb$/.match(file).nil?
            Zgomot.set_last_error(nil)
            path = File.join(dir, file)
            Zgomot.logger.info "LOADED CREATED FILE: #{path}"
            begin
              load path
            rescue Exception => e
              Zgomot.set_last_error(e.message)
            end
          end
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
