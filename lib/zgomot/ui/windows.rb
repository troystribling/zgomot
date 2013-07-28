module Zgomot::UI
  WIDTH = 80
  GLOBALS_HEIGHT = 6
  STREAMS_HEIGHT = 20
  CCS_TOP = GLOBALS_HEIGHT + STREAMS_HEIGHT
  COLOR_GREEN = Curses::COLOR_GREEN
  COLOR_BLUE = Curses::COLOR_BLUE
  COLOR_BLACK = Curses::COLOR_BLACK
  COLOR_WHITE = Curses::COLOR_WHITE
  COLOR_YELLOW = Curses::COLOR_YELLOW
  COLOR_CYAN = Curses::COLOR_CYAN
  COLOR_RED = Curses::COLOR_RED
  COLOR_MAGENTA = Curses::COLOR_MAGENTA
  module Utils
    def set_color(window, color, &blk)
      window.attron(Curses.color_pair(color)|Curses::A_NORMAL, &blk)
    end
    def refresh(window)
      window.clear
      yield
      window.refresh
    end
  end
  class MainWindow
    class << self
      attr_reader :thread, :globals_window, :cc_window, :str_window
      def init_curses
        Curses.noecho
        Curses.init_screen
        Curses.start_color
        Curses.curs_set(0)
        Curses.init_pair(COLOR_GREEN,COLOR_GREEN,COLOR_BLACK)
        Curses.init_pair(COLOR_WHITE,COLOR_WHITE,COLOR_BLACK)
        Curses.init_pair(COLOR_YELLOW,COLOR_YELLOW,COLOR_BLACK)
        Curses.init_pair(COLOR_CYAN,COLOR_CYAN,COLOR_BLACK)
        Curses.init_pair(COLOR_RED,COLOR_RED,COLOR_BLACK)
        Curses.init_pair(COLOR_MAGENTA,COLOR_MAGENTA,COLOR_BLACK)
      end
      def start_updates
        @thread = Thread.new do
                    loop do
                      globals_window.update
                      sleep(Zgomot::Midi::Clock.beat_sec)
                    end
                  end
      end
      def dash
        init_curses
        main_window = Curses::Window.new(0, 0, 0, 0)
        @globals_window = GlobalsWindow.new(main_window, 0)
        @cc_window = CCWindow.new(main_window, Curses.lines - CCS_TOP, CCS_TOP)
        @str_window = StrWindow.new(main_window, GLOBALS_HEIGHT)
        main_window.refresh
        start_updates
        loop do
          case main_window.getch
          #when Curses::Key::UP then ttt.move(0,-1)
          #when Curses::Key::DOWN then ttt.move(0,1)
          when ?q
            main_window.close
            Curses.close_screen
            @thread.kill
            break
          end
        end
      end
    end
  end
  class GlobalsWindow
    ITEM_WIDTH = 32
    TIME_WIDTH = 15
    attr_reader :time
    def initialize(parent_window, top)
      output = Zgomot::Drivers::Mgr.output
      input = Zgomot::Drivers::Mgr.input || 'None'
      beats_per_minute = Zgomot.config[:beats_per_minute]
      time_signature = Zgomot.config[:time_signature]
      resolution = Zgomot.config[:resolution]
      seconds_per_beat = Zgomot::Midi::Clock.beat_sec
      TitleWindow.new(parent_window, 'zgomot', COLOR_WHITE, 0, COLOR_MAGENTA)
      TextWithValueWindow.new(parent_window, 'Input', input, COLOR_WHITE, ITEM_WIDTH, 3, 0)
      TextWithValueWindow.new(parent_window, 'Output', output, COLOR_WHITE, ITEM_WIDTH, 4, 0)
      TextWithValueWindow.new(parent_window, 'Time Signature', time_signature, COLOR_WHITE, ITEM_WIDTH, 5, 0)
      TextWithValueWindow.new(parent_window, 'Beats/Minute', beats_per_minute, COLOR_WHITE, ITEM_WIDTH, 3, ITEM_WIDTH)
      TextWithValueWindow.new(parent_window, 'Seconds/Beat', seconds_per_beat, COLOR_WHITE, ITEM_WIDTH, 4, ITEM_WIDTH)
      TextWithValueWindow.new(parent_window, 'Resolution', resolution, COLOR_WHITE, ITEM_WIDTH, 5, ITEM_WIDTH)
      @time = TextWindow.new(parent_window, time_to_s, COLOR_GREEN, TIME_WIDTH, 3, WIDTH - TIME_WIDTH)
    end
    def time_to_s
      "%#{TIME_WIDTH}s" % /(\d*:\d*)/.match(Zgomot::Midi::Dispatcher.clk).captures.first
    end
    def update
      time.text = time_to_s
    end
  end
  class StrWindow
    attr_accessor :window, :rows, :streams, :widths
    def initialize(parent_window, top)
      @widths = Zgomot::UI::Output::STREAM_OUTPUT_FORMAT_WIDTHS
      @rows = []
      TitleWindow.new(parent_window, 'Streams', COLOR_WHITE, top, COLOR_CYAN)
      TableRowWindow.new(parent_window, Zgomot::UI::Output::STREAM_HEADER, widths, COLOR_WHITE, top+3, COLOR_CYAN)
      add_streams(parent_window, top+4)
    end
    def update
    end
    private
      def add_streams(window, top)
        @streams = Zgomot::Midi::Stream.streams
        streams.each do |stream|
          @rows << TableRowWindow.new(window, stream.info,  widths, COLOR_WHITE, top, COLOR_YELLOW)
          top += 1
        end
        (STREAMS_HEIGHT - streams.length - 4).times do
          TableRowWindow.new(window, nil,  widths, COLOR_WHITE, top, COLOR_YELLOW)
          top += 1
        end
      end
  end
  class CCWindow
    def initialize(parent_window, height, top)
      widths = Zgomot::UI::Output::CC_OUTPUT_FORMAT_WIDTHS
      TitleWindow.new(parent_window, 'Input CCs', COLOR_WHITE, top, COLOR_CYAN)
      TableRowWindow.new(parent_window, Zgomot::UI::Output::CC_HEADER, widths, COLOR_WHITE, top+3, COLOR_CYAN)
    end
    def update
    end
  end
  class TextWindow
    include Utils
    attr_reader :text, :window, :color
    def initialize(parent_window, text, color, width, top, left)
      @color = color
      @window = parent_window.subwin(1, width, top, left)
      set_color(window, color) {window << text}
    end
    def text=(text)
      refresh(window){set_color(window, color) {window << text}}
    end
  end
  class TextWithValueWindow
    include Utils
    attr_reader :text, :value, :window, :color, :value_color
    def initialize(parent_window, text, value, color, width, top, left, value_color=nil)
      @color, @text, @value = color, text, value
      @value_color = value_color || color
      @window = parent_window.subwin(1, width, top, left)
      display
    end
    def value=(value)
      @value = value
      refresh(window){display}
    end
    private
      def display
        set_color(window, color) {window << "#{text}: "}
        set_color(window, value_color) {window << "#{value}"}
      end
  end
  class TableRowWindow
    include Utils
    attr_reader :window, :rows, :color, :value_color, :values
    def initialize(parent_window, values, widths, color, top, value_color=nil)
      @color, @values, left = color, values, 0
      @rows = (0..widths.length-1).reduce([]) do|rs, i|
                width = widths[i]
                value = values.nil? ? '' : values[i]
                win = TableCellWindow.new(parent_window, "%-#{width}s" % value, color, width, top, left, value_color)
                left += width
                rs << win
              end
    end
    def row=(values)
      (0..rows.length-1).each do |i|
        refresh(rows[i]){rows[i].value = values[i]}
      end
    end
  end
  class TableCellWindow
    include Utils
    attr_reader :value, :window, :color, :value_color, :left
    def initialize(parent_window, value, color, width, top, left, value_color = nil)
      @color, @value, @left = color, value, left
      @value_color = value_color || color
      @window = parent_window.subwin(1, width, top, left)
      display
    end
    def value=(value)
      @value = value
      refresh(window){display}
    end
    private
      def display
        set_color(window, color) {window << '|'} if left == 0
        set_color(window, value_color) {window << value}
        set_color(window, color) {window << '|'}
      end
  end
  class TitleWindow
    include Utils
    attr_reader :window, :title, :color
    def initialize(parent_window, text, color, top, text_color = nil)
      text_color ||= color
      @color = color
      @window = parent_window.subwin(3, WIDTH, top, 0)
      set_color(window, color){window.box(?|, ?-)}
      title_len = text.length
      @title = window.subwin(1, title_len, top + 1, (WIDTH - title_len)/2)
      set_color(title, text_color){title << text}
    end
  end
end

