class Zgomot::Drivers
  class Mgr
    class << self
      extend Forwardable
      def_delegators :@driver, :sources, :destinations, :input, :output,
                               :add_input, :remove_input
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
    end
    load_driver
  end
end
