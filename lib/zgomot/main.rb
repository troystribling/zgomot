##############################################################################################################
module Zgomot
  
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
    delegate Zgomot::Midi::Stream, :str
    delegate Zgomot::Midi::Channel, :ch
    delegate Zgomot::Comp::Patterns, :n, :c

  #### Delegator 
  end
    
#### AgentXmpp 
end

##############################################################################################################
include Zgomot::Delegator

##############################################################################################################
at_exit do 
  Zgomot::Boot.boot
  sleep unless Zgomot.live
end
