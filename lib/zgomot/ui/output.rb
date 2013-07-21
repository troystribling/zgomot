module Zgomot::UI
  class Output
    @stream_mgr = Zgomot::Midi::Stream
    @cc_mgr = Zgomot::Midi::CC
    class << self
      attr_reader :stream_mgr, :cc_mgr
      HEADER_COLOR = '#666666'
      STREAM_OUTPUT_FORMAT_WIDTHS = [30, 10, 10, 10, 10, 10]
      STREAM_HEADER = %w(Name Status Chan Count Limit Delay)
      STREAM_STATUS_PLAY_COLOR = '#19D119'
      STREAM_STATUS_PAUSE_COLOR = '#EAC117'
      CC_OUTPUT_FORMAT_WIDTHS = [30, 10, 8, 8, 8, 8, 8]
      CC_HEADER = %w(Name Value CC Chan Type Max Min)
      CC_COLOR = '#EAC117'
      def lstr(name=nil)
        puts format_for_color(STREAM_OUTPUT_FORMAT_WIDTHS, HEADER_COLOR) % color(STREAM_HEADER, HEADER_COLOR)
        streams(name).each{|stream| puts stream}; nil
      end
      def lcc(name=nil)
        puts format_for_color(CC_OUTPUT_FORMAT_WIDTHS, HEADER_COLOR) % color(CC_HEADER, HEADER_COLOR)
        ccs(name).each{|cc| puts cc}; nil
      end
      private
        def color(string, color)
          Array(string).map{|s| s.to_s.foreground(color)}
        end
        def format_for_color(widths, color)
          color_offset = "".color(color).length
          widths.map{|width| "%-#{width+color_offset}s"}.join(" ")
        end
        def stream_info(stream)
          stream_output = [stream.name, stream.status, stream.ch, stream.count, stream.limit, stream.delay]
          if stream.status_eql?(:playing)
            format_for_color(STREAM_OUTPUT_FORMAT_WIDTHS, STREAM_STATUS_PLAY_COLOR) % color(stream_output, STREAM_STATUS_PLAY_COLOR)
          else
            format_for_color(STREAM_OUTPUT_FORMAT_WIDTHS, STREAM_STATUS_PAUSE_COLOR) % color(stream_output, STREAM_STATUS_PAUSE_COLOR)
          end
        end
        def streams(name=nil)
          if name.nil?
            stream_mgr.streams.map{|stream| stream_info(stream)}
          else
            [stream_mgr.apply_to_stream(name.to_s){|stream| stream_info(stream)}]
          end
        end
        def cc_config(name, channel, config)
          val, max, min = if config[:type] == :cont
                            ["%3.2f" % config[:value], "%3.2f" % config[:max], "%3.2f" % config[:min]]
                          else
                            [config[:value].to_s, '-', '-']
                          end
          cc_output = [name, val, config[:cc].to_s, channel.to_s, config[:type].to_s, max, min]
          format_for_color(CC_OUTPUT_FORMAT_WIDTHS, CC_COLOR) % color(cc_output, CC_COLOR)
        end
        def cc_info(name, info)
          info.map{|(ch, config)| cc_config(name, ch, config)}
        end
        def ccs(name=nil)
          if name.nil?
            cc_mgr.vars.map{|(cc_name, info)| cc_info(cc_name, info)}.flatten
          else
            cc_info(name.to_sym, cc_mgr.vars[name])
          end
        end
    end
  end
end
