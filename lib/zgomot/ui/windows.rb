module Zgomot::UI
  WIDTH = 80
  GLOBALS_HEIGHT = 6
  STREAMS_HEIGHT = 20
  CCS_TOP = GLOBALS_HEIGHT + STREAMS_HEIGHT
  COLOR_GREY = 100
  COLOR_GOLD = 101
  COLOR_GREEN = 202
  COLOR_PINK = 103
  COLOR_BLUE = 104
  COLOR_BLACK = Curses::COLOR_BLACK
  COLOR_WHITE = Curses::COLOR_WHITE
  COLOR_VIOLET = 209
  COLOR_MAGENTA = 210
  COLOR_YELLOW_GREEN = 211
  COLOR_LIGHT_BLUE = 212
  COLOR_ORANGE = 213

  COLOR_STREAM_PLAYING_SELECTED = 205
  COLOR_STREAM_PAUSED_SELECTED = 206
  COLOR_CC_SWITCH_TRUE = 207
  COLOR_CC_SWITCH_FALSE = 208
  COLOR_IDLE = 204
  COLOR_ACTIVE = 203
  COLOR_BORDER = 201
  COLOR_CC_IDLE = 200
  COLOR_CC_ACTIVE = 199

  module Utils
    def set_color(color, &blk)
      Curses.attron(Curses.color_pair(color)|Curses::A_NORMAL, &blk)
    end
    def write(y, x, str)
      Curses.setpos(y, x)
      Curses.addstr(str)
    end
  end
  class MainWindow
    class << self
      attr_reader :globals_window, :cc_window, :str_window, :main_window
      def init_curses
        Curses.init_screen
        Curses.noecho
        Curses.stdscr.keypad(true)
        Curses.start_color
        Curses.curs_set(0)
        Curses.init_color(COLOR_GREY, 700, 700, 700)
        Curses.init_color(COLOR_GOLD, 1000, 840, 0)
        Curses.init_color(COLOR_GREEN, 484, 980, 0)
        Curses.init_color(COLOR_PINK, 1000, 100, 575)
        Curses.init_color(COLOR_BLUE, 117, 575, 1000)
        Curses.init_color(COLOR_VIOLET, 810, 410, 980)
        Curses.init_color(COLOR_MAGENTA, 1000, 200, 1000)
        Curses.init_color(COLOR_YELLOW_GREEN, 750, 980, 410)
        Curses.init_color(COLOR_LIGHT_BLUE,600, 1000, 1000)
        Curses.init_color(COLOR_ORANGE,1000 , 600, 0)
        Curses.init_pair(COLOR_GOLD,COLOR_GOLD,COLOR_BLACK)
        Curses.init_pair(COLOR_GREEN,COLOR_GREEN,COLOR_BLACK)
        Curses.init_pair(COLOR_PINK,COLOR_PINK,COLOR_BLACK)
        Curses.init_pair(COLOR_BLUE,COLOR_BLUE,COLOR_BLACK)
        Curses.init_pair(COLOR_BORDER,COLOR_GREY,COLOR_BLACK)
        Curses.init_pair(COLOR_IDLE,COLOR_GOLD,COLOR_BLACK)
        Curses.init_pair(COLOR_ACTIVE,COLOR_GREEN,COLOR_BLACK)
        Curses.init_pair(COLOR_STREAM_PLAYING_SELECTED,COLOR_BLACK,COLOR_GREEN)
        Curses.init_pair(COLOR_STREAM_PAUSED_SELECTED,COLOR_BLACK,COLOR_GOLD)
        Curses.init_pair(COLOR_CC_SWITCH_TRUE,COLOR_ORANGE,COLOR_BLACK)
        Curses.init_pair(COLOR_CC_SWITCH_FALSE,COLOR_LIGHT_BLUE,COLOR_BLACK)
        Curses.init_pair(COLOR_CC_IDLE,COLOR_VIOLET,COLOR_BLACK)
        Curses.init_pair(COLOR_CC_ACTIVE,COLOR_BLACK,COLOR_VIOLET)
      end
      def update
        globals_window.display
        cc_window.display
        str_window.display
        Curses.refresh
      end
      def poll
        @thread = Thread.new do
                    loop do
                      update
                      sleep(Zgomot::Midi::Clock.beat_sec)
                    end
                  end
      end
      def dash
        init_curses
        @globals_window = GlobalsWindow.new(0)
        @cc_window = CCWindow.new(Curses.lines - CCS_TOP, CCS_TOP)
        @str_window = StrWindow.new(GLOBALS_HEIGHT)
        Curses.refresh
        poll
        loop do
          case Curses.getch
          when ?t
            str_window.set_tog_mode
            update
          when Curses::Key::UP
            str_window.dec_selected
            update
          when Curses::Key::DOWN
            str_window.inc_selected
            update
          when 10
            str_window.tog
            update
          when ?p
            Zgomot::Midi::Stream.play
            update
          when ?s
            Zgomot::Midi::Stream.stop
            update
          when ?q
            @thread.kill
            Curses.close_screen
            break
          end
        end
      end
    end
  end

  class GlobalsWindow
    ITEM_WIDTH = 32
    TIME_WIDTH = 15
    attr_reader :time_window, :title_window, :input_window, :output_window, :time_signature_window,
      :beats_per_minute_window, :seconds_per_beat_window, :resolution_window
    def initialize(top)
      output = Zgomot::Drivers::Mgr.output
      input = Zgomot::Drivers::Mgr.input || 'None'
      beats_per_minute = Zgomot::Midi::Clock.beats_per_minute.to_i.to_s
      time_signature = Zgomot::Midi::Clock.time_signature
      resolution = "1/#{Zgomot::Midi::Clock.resolution.to_i}"
      seconds_per_beat = Zgomot::Midi::Clock.beat_sec.to_s
      @title_window = TitleWindow.new('zgomot', COLOR_BORDER, 0, COLOR_PINK)
      @input_window = TextWithValueWindow.new('Input', input, COLOR_BORDER, 3, 0, COLOR_IDLE)
      @output_window = TextWithValueWindow.new('Output', output, COLOR_BORDER, 4, 0, COLOR_IDLE)
      @time_signature_window = TextWithValueWindow.new('Time Signature', time_signature, COLOR_BORDER, 5, 0, COLOR_IDLE)
      @beats_per_minute_window = TextWithValueWindow.new('Beats/Minute', beats_per_minute, COLOR_BORDER, 3, ITEM_WIDTH, COLOR_IDLE)
      @seconds_per_beat_window = TextWithValueWindow.new('Seconds/Beat', seconds_per_beat, COLOR_BORDER, 4, ITEM_WIDTH, COLOR_IDLE)
      @resolution_window = TextWithValueWindow.new('Resolution', resolution, COLOR_BORDER, 5, ITEM_WIDTH, COLOR_IDLE)
      @time_window = TextWindow.new(time_to_s, COLOR_ACTIVE, 3, WIDTH - TIME_WIDTH)
    end
    def time_to_s
      "%#{TIME_WIDTH}s" % /(\d*:\d*)/.match(Zgomot::Midi::Dispatcher.clk).captures.first
    end
    def display
      title_window.display
      time_window.display(time_to_s)
      input_window.display
      output_window.display
      time_signature_window.display
      beats_per_minute_window.display
      seconds_per_beat_window.display
      resolution_window.display
    end
  end

  class StrWindow
    attr_reader :selected, :tog_mode, :window, :rows, :widths
    def initialize(top)
      @tog_mode, @selected = false, 0
      @widths = Zgomot::UI::Output::STREAM_OUTPUT_FORMAT_WIDTHS
      TitleWindow.new('Streams', COLOR_BORDER, top, COLOR_BLUE)
      TableRowWindow.new(Zgomot::UI::Output::STREAM_HEADER, widths, COLOR_BORDER, top + 3, COLOR_BORDER)
      add_streams(top + 3)
    end
    def display
      (0..streams.length-1).each do |i|
        stream = streams[i]
        rows[i].display(stream.info, stream_color(stream, i))
      end
    end
    def inc_selected
      if tog_mode
       @selected = (selected + 1) % streams.length
      end
    end
    def dec_selected
      if tog_mode
        @selected = (selected - 1) % streams.length
      end
    end
    def set_tog_mode
      @selected = 0
      @tog_mode = tog_mode ? false : true
    end
    def tog
      stream = streams[selected]
      Zgomot::Midi::Stream.tog(stream.name)
      set_tog_mode
    end
    private
      def add_streams(top)
        @rows = (0..streams.length-1).map do |i|
                  stream = streams[i]
                  TableRowWindow.new(stream.info, widths, COLOR_BORDER, top += 1, stream_color(stream, i))
                end
        (STREAMS_HEIGHT - streams.length - 4).times do
          TableRowWindow.new(nil,  widths, COLOR_BORDER, top += 1)
        end
      end
      def stream_color(stream, i)
        if tog_mode && i == selected
          stream.status_eql?(:playing) ? COLOR_STREAM_PLAYING_SELECTED : COLOR_STREAM_PAUSED_SELECTED
        else
          stream.status_eql?(:playing) ? COLOR_ACTIVE : COLOR_IDLE
        end
      end
      def streams
        Zgomot::Midi::Stream.streams
      end
  end

  class CCWindow
    attr_reader :height, :widths, :rows
    def initialize(height, top)
      @height = height
      @widths = Zgomot::UI::Output::CC_OUTPUT_FORMAT_WIDTHS
      TitleWindow.new('Input CCs', COLOR_BORDER, top, COLOR_BLUE)
      TableRowWindow.new(Zgomot::UI::Output::CC_HEADER, widths, COLOR_BORDER, top + 3, COLOR_BORDER)
      add_ccs(top + 3)
    end
    def display
      ccs = get_ccs
      (0..ccs.length-1).each{|i| rows[i].display(ccs[i], cc_color(ccs[i]))}
    end
    private
      def add_ccs(top)
        ccs = get_ccs
        @rows = ccs.map do |cc_params|
          puts cc_color(cc_params)
                  TableRowWindow.new(cc_params, widths, COLOR_BORDER, top += 1, cc_color(cc_params))
                end
        (height - ccs.length - 4).times do
          TableRowWindow.new(nil,  widths, COLOR_BORDER, top += 1)
        end
      end
      def cc_name(cc_params); cc_params[0]; end
      def cc_ch(cc_params); cc_params[3]; end
      def cc_type(cc_params); cc_params[4]; end
      def cc_value(cc_params); cc_params[1]; end
      def cc_updated_at(cc_params)
        Zgomot::Midi::CC.update_at(cc_name(cc_params), cc_ch(cc_params))
      end
      def get_ccs
        cc_mgr = Zgomot::Midi::CC
        cc_mgr.cc_names.reduce([]){|c, cc_name| c + cc_mgr.info(cc_name)}
      end
      def cc_color(cc)
        COLOR_IDLE
        if cc_type(cc).eql?('cont')
          delta = Time.now - cc_updated_at(cc)
          delta > Zgomot::Midi::Clock.beat_sec ? COLOR_CC_IDLE : COLOR_CC_ACTIVE
        else
          cc_value(cc).eql?('true') ? COLOR_CC_SWITCH_TRUE : COLOR_CC_SWITCH_FALSE
        end
      end
  end

  class TextWindow
    include Utils
    attr_reader :text, :top, :color, :left
    def initialize(text, color, top, left)
      @color, @top, @left, @text = color, top, left, text
      display(text)
    end
    def display(new_text=nil)
      @text = new_text || text
      set_color(color) {
        write(top, left, text)
      }
    end
  end

  class TextWithValueWindow
    include Utils
    attr_reader :text, :top, :color, :value_color, :left, :value
    def initialize(text, value, color, top, left, value_color=nil)
      @color, @text, @top, @left, @value = color, text, top, left, value
      @value_color = value_color || color
      display(value)
    end
    def display(new_value=nil)
      @value = new_value || value
      text_len = text.length + 2
      set_color(color) {
        write(top, left, "#{text}: ")
      }
      set_color(value_color) {
        write(top, left+text_len, value)
      }
    end
  end

  class TableRowWindow
    include Utils
    attr_reader :window, :columns, :color, :value_color, :values, :widths
    def initialize(values, widths, color, top, value_color = COLOR_BORDER)
      left = 0
      @columns = (0..widths.length-1).reduce([]) do|rs, i|
                    width = widths[i]
                    value = values.nil? ? '' : values[i]
                    win = TableCellWindow.new(value, color, width, top, left, value_color)
                    left += width
                    rs << win
                end
    end
    def display(values, value_color)
      (0..columns.length-1).each do |i|
        columns[i].display(values[i], value_color)
      end
    end
  end

  class TableCellWindow
    include Utils
    attr_reader :value, :color, :left, :top, :width
    def initialize(value, color, width, top, left, value_color)
      @color, @value, @left, @top, @width = color, value, left, top, width
      display(value, value_color)
    end
    def display(value, value_color)
      offset = 0
      set_color(color) {
        if left == 0
          write(top, left, '|')
          offset += 1
        end
        write(top, left+width-1-offset, '|')
      }
      set_color(value_color) {
        write(top, left+offset, "%-#{width-offset-2}s" % value)
      }
    end
  end

  class TitleWindow
    include Utils
    attr_reader :windows, :text, :top, :color, :text_color
    def initialize(text, color, top, text_color = nil)
      @text_color = text_color || color
      @text, @color, @top = text, color, top
      display
    end
    def display
      set_color(color) {
        write(top, 0, '-' * WIDTH)
        write(top + 1, 0, '|')
        write(top + 1, WIDTH-1, '|')
        write(top + 2, 0, '-' * WIDTH)
      }
      set_color(text_color) {
        write(top + 1, 1, text.center(WIDTH-2))
      }
    end
  end

end

