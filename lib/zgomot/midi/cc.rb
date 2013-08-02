module Zgomot::Midi
  class CC

    @params = {}
    @ccs = {}

    class << self

      attr_reader :ccs, :params

      def add_cc(name, cc, args)
        channel = args[:channel].nil? ? 1 : args[:channel]
        min = args[:min].nil? ? 0.0 : args[:min]
        max = args[:max].nil? ? 1.0 : args[:max]
        type = args[:type] || :cont
        init = args[:init].nil? ? (type == :cont ? 0.0 : false) : args[:init]
        @ccs[cc] = name.to_sym
        (@params[name] ||= {})[channel] = {:min         => min,
                                           :max         => max,
                                           :value       => init,
                                           :type        => type,
                                           :updated_at  => ::Time.now,
                                           :cc          => cc}
        Zgomot.logger.info "ADDED CC #{cc}:#{name}:#{init}:#{channel}"
      end
      def learn_cc(name, cc, args)
      end
      def cc(name, channel = 1)
        raise(Zgomot::Error, " CC '#{name}' for channel '#{channel}' not found") if @params[name].nil? or @params[name][channel].nil?
        @params[name][channel][:value]
      end
      def channel_info(name, channel, config)
        val, max, min = if config[:type] == :cont
                          ["%3.2f" % config[:value], "%3.2f" % config[:max], "%3.2f" % config[:min]]
                        else
                          [config[:value].to_s, '-', '-']
                        end
        [name, val, config[:cc].to_s, channel.to_s, config[:type].to_s, max, min]
      end
      def cc_names
        params.keys
      end
      def info(name)
        params[name].map{|(ch, config)| channel_info(name, ch, config)}
      end
      def update_at(name, ch)
        params[name.to_sym][ch.to_i][:updated_at]
      end
      def apply(cc_num, value, channel)
        name = @ccs[cc_num]
        unless name.nil?
          Zgomot.logger.info "UPDATED CC #{cc}:#{name}:#{value}:#{channel}"
          p = @params[name][channel]
          min = p[:min]
          max = p[:max]
          p[:updated_at] = ::Time.now
          if p[:type] == :cont
            p[:value] = min + (max - min)*value.to_f/127.0
          else
            p[:value] = value == 127 ? true : false
          end
        end
      end

    end
  end
end
