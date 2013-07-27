module Zgomot::UI
  WIDTH = 80
  COLOR_GREEN = Curses::COLOR_GREEN
  COLOR_BLACK = Curses::COLOR_BLACK
  COLOR_WHITE = Curses::COLOR_WHITE
  COLOR_YELLOW = Curses::COLOR_YELLOW
  COLOR_CYAN = Curses::COLOR_CYAN
  COLOR_RED = Curses::COLOR_RED
  COLOR_MAGENTA = Curses::COLOR_MAGENTA
  def self.set_color(window, color, &blk)
    window.attron(Curses.color_pair(color)|Curses::A_NORMAL, &blk)
  end
  class Window
    class << self
      attr_reader :thread
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
                      @globals_window.update
                      sleep(0.5)
                    end
                  end
      end
      def dash
        init_curses
        win = Curses::Window.new(0, WIDTH, 0, 0)
        @globals_window = GlobalsWindow.new(win)
        win.refresh
        start_updates
        loop do
          case win.getch
          #when Curses::Key::UP then ttt.move(0,-1)
          #when Curses::Key::DOWN then ttt.move(0,1)
          when ?q
            win.close
            Curses.close_screen
            @thread.kill
            break
          end
        end
      end
    end
  end
  class GlobalsWindow
    HEIGHT = 4
    attr_reader :window, :title, :input, :output, :clock
    def initialize(parent_window)
      @window = parent_window.subwin(HEIGHT, WIDTH, 0, 0)
      @title = Title.new(window, 'zgomot', COLOR_WHITE, 0, COLOR_MAGENTA)
      @input = TextWithValue.new(window, 'Input', Zgomot::Drivers::Mgr.input || 'None', COLOR_WHITE, 26, 3, 0)
      @output = TextWithValue.new(window, 'Output', Zgomot::Drivers::Mgr.output, COLOR_WHITE, 26, 3, 26)
      @clock = Text.new(window, clock_to_s, COLOR_WHITE, 10, 3, WIDTH-10)
      window.refresh
    end
    def clock_to_s
      "%10s" % /(\d*:\d*)/.match(Zgomot::Midi::Dispatcher.clk).captures.first
    end
    def update
      clock.text = clock_to_s
    end
  end
  class StrWindow
    HEIGHT = 16
    attr_reader :window
    TOP = GlobalsWindow::HEIGHT
    def initialize(parent_window)
      @window = parent_window.subwin(HEIGHT, WIDTH, 0, 0)
    end
  end
  class CCWindow
    HEIGHT = Curses.lines - GlobalsWindow::HEIGHT - StrWindow::HEIGHT
    TOP = StrWindow::HEIGHT + GlobalsWindow::HEIGHT
    def initialize(parent_window)
    end
  end
  class Text
    attr_reader :text, :window, :color
    def initialize(parent_window, text, color, width, top, left)
      @color = color
      @window = parent_window.subwin(1, width, top, left)
      Zgomot::UI.set_color(window, color) {window << text}
    end
    def text=(text)
      window.clear
      Zgomot::UI.set_color(window, color) {window << text}
      window.refresh
    end
  end
   class TextWithValue
    attr_reader :text, :value, :window, :color
    def initialize(parent_window, text, value, color, width, top, left)
      @color = color
      @window = parent_window.subwin(1, width, top, left)
      Zgomot::UI.set_color(window, color) {
        @window << "#{text}: #{value}"
      }
    end
    def value=(value)
      @window.clear
      Zgomot::UI.set_color(window, color) {
        @window << "#{text}: #{value}"
      }
    end
  end
  class TextRow
    attr_reader :windows, :color
    def initialize(parent_window, values, color, top)
      @color = color
      @windows = values.reduce([]) do|wins, (v, w)|
                   win = parent_window.subwin(1, w, top, 0)
                   set_color(win. color){win << v}
                   wins << win
                 end
    end
    def row=(values)
      @windows.each do |w|
        w.clear
        w.attron(Curses.color_pair(color)|Curses::A_NORMAL) {w << v.shift}
      end
    end
  end
  class Title
    attr_reader :window, :title, :color
    def initialize(parent_window, text, color, top, text_color = nil)
      text_color ||= color
      @color = color
      @window = parent_window.subwin(3, WIDTH, 0, top)
      Zgomot::UI.set_color(window, color){window.box(?|, ?-)}
      title_len = text.length
      @title = window.subwin(1, title_len, 1, (WIDTH - title_len)/2)
      Zgomot::UI.set_color(title, text_color){title << text}
    end
  end
end

