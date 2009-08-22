##############################################################################################################
module Zgomot

  #####-------------------------------------------------------------------------------------------------------
  class Boot
    
    ####......................................................................................................
    class << self

      #.......................................................................................................
      def boot
        
        ####..............
        Zgomot.logger = Logger.new(STDOUT)
        Zgomot.logger.level = Logger::WARN 

        ####..............
        call_if_implemented(:call_before_start)

        ####..............
        Zgomot.logger.info "ZGOMOT BEGINNING"
        Zgomot.logger.info "APPLICATION PATH: #{Zgomot.app_path}"
        Zgomot.logger.info "CONFIGURATION FILE: #{Zgomot.config_file}"
        Zgomot.logger.info "CONFIGURATION: #{Zgomot.config.inspect}"    
        
      end
      
      ####....................................................................................................
      # application deligate methods
      #.......................................................................................................
      def call_if_implemented(method, *args)
        send(method, *args) if respond_to?(method)
      end
      
      #.........................................................................................................
      def callbacks(*args)
        args.each do |meth| 
          instance_eval <<-do_eval
            def #{meth}(&blk)
              define_meta_class_method(:call_#{meth}, &blk)
            end
          do_eval
        end
      end 
                                  
    #### self
    end

    #.........................................................................................................
    callbacks(:before_start)

  #### Boot
  end
  
#### Zgomot
end
