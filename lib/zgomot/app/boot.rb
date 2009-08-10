##############################################################################################################
module Zgomot

  #####-------------------------------------------------------------------------------------------------------
  class Boot
    
    ####......................................................................................................
    class << self

      #.......................................................................................................
      def boot
        
        ####..............
        Zgomot.log_file = add_path(Zgomot.log_file) if Zgomot.log_file.kind_of?(String)
        Zgomot.config_file = add_path(Zgomot.config_file)
        Zgomot.logger = Logger.new(Zgomot.log_file, 10, 1024000)

        ####..............
        Zgomot.logger.info "STARTING Zgomot"
        Zgomot.logger.info "APPLICATION PATH: #{Zgomot.app_path}"
        Zgomot.logger.info "LOG FILE: #{Zgomot.log_file.kind_of?(String) ? Zgomot.log_file : "STDOUT"}"
        Zgomot.logger.info "CONFIGURATION FILE: #{Zgomot.config_file}"
        Zgomot.logger.level = Logger::WARN 

        ####..............
        raise ZgomotError, "Configuration file #{Zgomot.config_file} required." unless  

        ####..............
        config = if File.exist?(Zgomot.config_file)
                   (c = File.open(Zgomot.config_file) {|yf| YAML::load(yf)}) ? c : {}
                 else; {}; end
        Zgomot.config = Zgomot::DEFAULT_CONFIG.inject({}){|r,(k,v)| r.update(k => (config[k] || v))}         
                          
        call_if_implemented(:call_before_start)
        
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
                          
    ####......................................................................................................
    private

      #.......................................................................................................
      def add_path(dir)
        File.join(Zgomot.app_path, dir)
      end
        
    #### self
    end

    #.........................................................................................................
    callbacks(:before_start)

  #### Boot
  end
  
#### Zgomot
end
