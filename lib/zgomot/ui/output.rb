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
        format_streams(name).each{|stream| puts stream}; nil
      end
      def lcc(name=nil)
        puts format_for_color(CC_OUTPUT_FORMAT_WIDTHS, HEADER_COLOR) % color(CC_HEADER, HEADER_COLOR)
        format_ccs(name).each{|cc| puts cc}; nil
      end
      private
        def color(string, color)
          Array(string).map{|s| s.to_s.foreground(color)}
        end
        def format_for_color(widths, color)
          color_offset = "".color(color).length
          widths.map{|width| "%-#{width+color_offset}s"}.join(" ")
        end
        def format_stream_info(stream)
          stream_output = stream.info(stream)
          if stream.status_eql?(:playing)
            format_for_color(STREAM_OUTPUT_FORMAT_WIDTHS, STREAM_STATUS_PLAY_COLOR) % color(stream_output, STREAM_STATUS_PLAY_COLOR)
          else
            format_for_color(STREAM_OUTPUT_FORMAT_WIDTHS, STREAM_STATUS_PAUSE_COLOR) % color(stream_output, STREAM_STATUS_PAUSE_COLOR)
          end
        end
        def format_streams(name=nil)
          if name.nil?
            stream_mgr.streams.map{|stream| format_stream_info(stream)}
          else
            [stream_mgr.apply_to_stream(name.to_s){|stream| stream_info(stream)}]
          end
        end
        def format_cc_config(name, channel, config)
          cc_output = cc_mgr.info(name, channel, config)
          format_for_color(CC_OUTPUT_FORMAT_WIDTHS, CC_COLOR) % color(cc_output, CC_COLOR)
        end
        def format_cc_info(name, info)
          info.map{|(ch, config)| format_cc_config(name, ch, config)}
        end
        def format_ccs(name=nil)
          if name.nil?
            cc_mgr.vars.map{|(cc_name, info)| format_cc_info(cc_name, info)}.flatten
          else
            format_cc_info(name.to_sym, cc_mgr.vars[name])
          end
        end
    end
  end
end
