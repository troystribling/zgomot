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
  COLOR_IDLE = COLOR_GOLD
  COLOR_ACTIVE = COLOR_GREEN
  COLOR_BLACK = Curses::COLOR_BLACK
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
        Curses.start_color
        Curses.curs_set(0)
        Curses.init_color(COLOR_GREY, 700, 700, 700)
        Curses.init_color(COLOR_GOLD, 1000, 840, 0)
        Curses.init_color(COLOR_GREEN, 484, 980, 0)
        Curses.init_color(COLOR_PINK, 1000, 100, 575)
        Curses.init_color(COLOR_BLUE, 117, 575, 1000)
        Curses.init_pair(COLOR_GREY,COLOR_GREY,COLOR_BLACK)
        Curses.init_pair(COLOR_GOLD,COLOR_GOLD,COLOR_BLACK)
        Curses.init_pair(COLOR_GREEN,COLOR_GREEN,COLOR_BLACK)
        Curses.init_pair(COLOR_PINK,COLOR_PINK,COLOR_BLACK)
        Curses.init_pair(COLOR_BLUE,COLOR_BLUE,COLOR_BLACK)
      end
      def update
        globals_window.display
        #cc_window.update
        #str_window.update
        Curses.refresh
      end
      def dash
        init_curses
        @globals_window = GlobalsWindow.new(0)
        #@cc_window = CCWindow.new(Curses.lines - CCS_TOP, CCS_TOP)
        #@str_window = StrWindow.new( GLOBALS_HEIGHT)
        Curses.refresh
        loop do
          case Curses.getch
          when ?q
            Curses.close_screen
            break
          when ?u
            update
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
      @title_window = TitleWindow.new('zgomot', COLOR_GREY, 0, COLOR_PINK)
      @input_window = TextWithValueWindow.new('Input', input, COLOR_GREY, 3, 0, COLOR_IDLE)
      @output_window = TextWithValueWindow.new('Output', output, COLOR_GREY, 4, 0, COLOR_IDLE)
      @time_signature_window = TextWithValueWindow.new('Time Signature', time_signature, COLOR_GREY, 5, 0, COLOR_IDLE)
      @beats_per_minute_window = TextWithValueWindow.new('Beats/Minute', beats_per_minute, COLOR_GREY, 3, ITEM_WIDTH, COLOR_IDLE)
      @seconds_per_beat_window = TextWithValueWindow.new('Seconds/Beat', seconds_per_beat, COLOR_GREY, 4, ITEM_WIDTH, COLOR_IDLE)
      @resolution_window = TextWithValueWindow.new('Resolution', resolution, COLOR_GREY, 5, ITEM_WIDTH, COLOR_IDLE)
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
    attr_accessor :window, :rows, :widths
    def initialize(parent_window, top)
      @widths = Zgomot::UI::Output::STREAM_OUTPUT_FORMAT_WIDTHS
      TitleWindow.new(parent_window, 'Streams', COLOR_GREY, top, COLOR_BLUE)
      TableRowWindow.new(parent_window, Zgomot::UI::Output::STREAM_HEADER, widths, COLOR_GREY, top + 3)
      add_streams(parent_window, top + 3)
    end
    def update
      streams = Zgomot::Midi::Stream.streams
      (0..streams.length-1).each do |i|
        rows[i].update(streams[i].info, stream_color(streams[i]))
      end
    end
    private
      def add_streams(window, top)
        streams = Zgomot::Midi::Stream.streams
        @rows = streams.map do |stream|
                  TableRowWindow.new(window, stream.info,  widths, COLOR_GREY, top += 1, stream_color(stream))
                end
        (STREAMS_HEIGHT - streams.length - 4).times do
          TableRowWindow.new(window, nil,  widths, COLOR_GREY, top += 1, COLOR_GOLD)
        end
      end
      def stream_color(stream)
        stream.status_eql?(:playing) ? COLOR_ACTIVE : COLOR_IDLE
      end
  end

  class CCWindow
    attr_accessor :height, :widths, :rows
    def initialize(parent_window, height, top)
      @height = height
      @widths = Zgomot::UI::Output::CC_OUTPUT_FORMAT_WIDTHS
      TitleWindow.new(parent_window, 'Input CCs', COLOR_GREY, top, COLOR_BLUE)
      TableRowWindow.new(parent_window, Zgomot::UI::Output::CC_HEADER, widths, COLOR_GREY, top + 3)
      add_ccs(parent_window, top + 3)
    end
    def update
      ccs = get_ccs
      (0..ccs.length-1).each{|i| rows[i].update(ccs[i])}
    end
    private
      def add_ccs(window, top)
        ccs = get_ccs
        @rows = ccs.map do |cc|
                  TableRowWindow.new(window, cc, widths, COLOR_GREY, top += 1, COLOR_GOLD)
                end
        (height - ccs.length - 4).times do
          TableRowWindow.new(window, nil,  widths, COLOR_GREY, top += 1, COLOR_GOLD)
        end
      end
      def get_ccs
        cc_mgr = Zgomot::Midi::CC
        cc_mgr.cc_names.reduce([]){|c, cc_name| c + cc_mgr.info(cc_name)}
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
    def initialize(parent_window, values, widths, color, top, value_color=nil)
      @color, @values, @widths, left = color, values, widths, 0
      @columns = (0..widths.length-1).reduce([]) do|rs, i|
                    width = widths[i]
                    value = values.nil? ? '' : values[i]
                    win = TableCellWindow.new(parent_window, "%-#{width}s" % value, color, width, top, left, value_color)
                    left += width
                    rs << win
                end
    end
    def update(values, new_color=nil)
      (0..columns.length-1).each do |i|
        columns[i].update("%-#{widths[i]}s" % values[i], new_color)
      end
    end
  end

  class TableCellWindow
    include Utils
    attr_reader :value, :color, :value_color, :left, :top
    def initialize(value, color, top, left, value_color = nil)
      @color, @value, @left, @top = color, value, left, top
      @value_color = value_color || color
      display
    end
    def update(value, new_color = nil)
      @value_color = new_color || value_color
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

