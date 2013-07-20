module Zgomot::Midi
  class CC

    @vars = {}
    @ccs = {}

    class << self

      def add_cc(name, cc, args)
        channel = args[:channel].nil? ? 1 : args[:channel]
        min = args[:min].nil? ? 0.0 : args[:min]
        max = args[:max].nil? ? 1.0 : args[:max]
        type = args[:type] || :cont
        init = args[:init].nil? ? (type == :cont ? 0.0 : false) : args[:init]
        @ccs[cc] = name
        (@vars[name] ||= {})[channel] = {:min   => min,
                                         :max   => max,
                                         :value => init,
                                         :type  => type,
                                         :cc    => cc}
        Zgomot.logger.info "ADDED CC #{cc}:#{name}:#{init}:#{channel}"
      end

      def learn_cc(name, cc, args)
      end

      def lcc
      end

      def cc(name, channel = 1)
        raise(Zgomot::Error, " CC '#{name}' for channel '#{channel}' not found") if @vars[name].nil? or @vars[name][channel].nil?
        @vars[name][channel][:value]
      end

      def apply(cc, value, channel)
        name = @ccs[cc]
        unless name.nil?
          Zgomot.logger.info "UPDATED CC #{cc}:#{name}:#{value}:#{channel}"
          params = @vars[name][channel]
          min = params[:min]
          max = params[:max]
          if params[:type] == :cont
            params[:value] = min + (max - min)*value.to_f/127.0
          else
            params[:value] = value == 127 ? true : false
          end
        end
      end

    end
  end
end
