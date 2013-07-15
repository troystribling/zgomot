module Zgomot::Midi
  class CC
    class << self
      attr_reader :variables

      # interface
      def define_cc(name, cc, args)
        channel = args[:channel].nil? ? -1 : args[:channel]
        min = args[:min].nil? ? 0.0 : args[:min]
        max = args[:max].nil? ? 1.0 : args[:max]
        init = args[:init].nil? ? 0.0 : args[:init]
        ((@variables ||= {})[name] ||= {})[channel] << {:min   => min,
                                                        :max   => mac,
                                                        :value => init,
                                                        :cc    => cc}
      end

      def cc(name, channel = -1)
        val = variables[name][channel]
        val.nil? ? raise(Zgomot::Error, " CC '#{name}' for channel '#{channel}' not found") : val
      end

      # internal
      def apply(cc, value, channel)
        raise(Zgomot::Error, " CC '#{cc}' for channel '#{channel}' not found") if variables[name][channel].nil?
        variables[name][channel] = value
      end

    end
  end
end
