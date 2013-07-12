class Zgomot::Drivers
  class Mgr
    class << self
      def load_driver
        driver_name = self.driver_name
        driver_path = "zgomot/drivers/#{driver_name}"
        Zgomot.logger.info "LOADING DRIVER: #{driver_path}"
        begin
          require driver_path
        rescue LoadError => e
          raise LoadError, "Could not load driver '#{driver_path}'."
        end
        driver_class = "Zgomot::Drivers::" + driver_name.split('_').map{|n| n.capitalize}.join
        @driver = Object.module_eval("::#{driver_class}").new
        Zgomot.logger.info "DRIVER #{driver_class} CREATED"
      end
      def driver_name
        case RUBY_PLATFORM
          when /darwin/
            'core_midi'
        else
           raise "platform not supported"
        end
      end
      def method_missing(method, *args)
        return @driver.send(method, *args)
      end
      # interface
      def dest
        @driver.destinations
      end
      def src
        @driver.sources
      end
    end
    load_driver
  end
end
