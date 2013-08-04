module Zgomot::UI
  class Output
    @stream_mgr = Zgomot::Midi::Stream
    @cc_mgr = Zgomot::Midi::CC
    @clk_mgr = Zgomot::Midi::Clock
    HEADER_COLOR = '#666666'
    STREAM_OUTPUT_FORMAT_WIDTHS = [30, 9, 6, 11, 9, 8, 7]
    STREAM_HEADER = %w(Name Status Chan Time Count Limit Delay)
    STREAM_STATUS_PLAY_COLOR = '#19D119'
    STREAM_STATUS_PAUSE_COLOR = '#EAC117'
    CC_OUTPUT_FORMAT_WIDTHS = [30, 10, 8, 8, 8, 8, 8]
    CC_HEADER = %w(Name Value CC Chan Type Max Min)
    CC_COLOR = '#EAC117'
    CONFIG_COLOR = '#EAC117'
    class << self
      attr_reader :stream_mgr, :cc_mgr, :clk_mgr
      def lstr(name=nil)
        puts format_for_color(STREAM_OUTPUT_FORMAT_WIDTHS, HEADER_COLOR) % color(STREAM_HEADER, HEADER_COLOR)
        format_streams(name).each{|stream| puts stream}; nil
      end
      def lcc(name=nil)
        puts format_for_color(CC_OUTPUT_FORMAT_WIDTHS, HEADER_COLOR) % color(CC_HEADER, HEADER_COLOR)
        format_ccs(name).each{|cc| puts cc}; nil
      end
      def lconfig
        format = '%-35s %-25s'
        puts format % ['Time Signature'.foreground(HEADER_COLOR), clk_mgr.time_signature.foreground(CONFIG_COLOR)]
        puts format % ['Beats/Minute'.foreground(HEADER_COLOR), clk_mgr.beats_per_minute.to_i.to_s.foreground(CONFIG_COLOR)]
        puts format % ['Resolution'.foreground(HEADER_COLOR), "1/#{clk_mgr.resolution.to_i}".foreground(CONFIG_COLOR)]
        puts format % ['Seconds/Beat'.foreground(HEADER_COLOR), clk_mgr.beat_sec.to_s.foreground(CONFIG_COLOR)]
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
          stream_output = stream.info
          value_color = stream.status_eql?(:playing) ? STREAM_STATUS_PLAY_COLOR : STREAM_STATUS_PAUSE_COLOR
          format_for_color(STREAM_OUTPUT_FORMAT_WIDTHS, value_color) % color(stream_output, value_color)
        end
        def format_streams(name=nil)
          if name.nil?
            stream_mgr.streams.values.map{|stream| format_stream_info(stream)}
          else
            [stream_mgr.apply_to_stream(name.to_s){|stream| stream_info(stream)}]
          end
        end
        def format_cc_config(config)
          format_for_color(CC_OUTPUT_FORMAT_WIDTHS, CC_COLOR) % color(config, CC_COLOR)
        end
        def format_cc_info(name)
          cc_mgr.info(name).map{|config| format_cc_config(config)}
        end
        def format_ccs(name=nil)
          if name.nil?
            cc_mgr.cc_names.reduce([]){|ccs, cc_name| ccs + format_cc_info(cc_name)}
          else
            format_cc_info(name.to_sym)
          end
        end
    end
  end
end
