##############################################################################################################
OptionParser.new do |opts|
  opts.banner = 'Usage: agent_xmpp.rb [options]'
  opts.separator ''
  opts.on('-c', '--config config.yml', 'YAML agent configuration file relative to application path') {|f| AgentXmpp.config_file = f}
  opts.on('-l', '--logfile file.log', 'name of logfile') {|f| AgentXmpp.log_file = f}
  opts.on_tail('-h', '--help', 'Show this message') {
    puts opts
    exit
  }
  opts.parse!(ARGV)
end

##############################################################################################################
module Zgomot
  
  #####-------------------------------------------------------------------------------------------------------
  class ZgomotError < Exception; end
  
  #####-------------------------------------------------------------------------------------------------------
  class << self            
  #### self
  end
  
  #####-------------------------------------------------------------------------------------------------------
  module Delegator 

    #####-------------------------------------------------------------------------------------------------------
    class << self

      #.........................................................................................................
      def delegate(del, *methods)
        methods.each do |method_name|
          class_eval <<-RUBY
            def #{method_name.to_s}(*args, &blk)
              ::#{del}.send(#{method_name.inspect}, *args, &blk)
            end
          RUBY
        end
      end

    #### self
    end

    delegate Zgomot::Boot, :before_start
    delegate Zgomot::Midi::Stream, :strm
    delegate Zgomot::Midi::Channel, :chize
    delegate Zgomot::Comp::Patterns, :n, :c

  #### Delegator 
  end
    
#### AgentXmpp 
end

##############################################################################################################
include Zgomot::Delegator

##############################################################################################################
at_exit {Zgomot::Boot.boot}
