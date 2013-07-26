module Zgomot::UI
  WIDTH = 80
  COLOR_GREEN = Curses::COLOR_GREEN
  COLOR_BLACK = Curses::COLOR_BLACK
  COLOR_WHITE = Curses::COLOR_WHITE
  COLOR_YELLOW = Curses::COLOR_YELLOW
  COLOR_CYAN = Curses::COLOR_CYAN
  COLOR_RED = Curses::COLOR_RED
  COLOR_MAGENTA = Curses::COLOR_MAGENTA
  class Window
    class << self
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
      def dash
        init_curses
        win = Curses::Window.new(0, WIDTH, 0, 0)
        str_win = Globals.new(win)
        win.refresh
        loop do
          case win.getch
          #when Curses::Key::UP then ttt.move(0,-1)
          #when Curses::Key::DOWN then ttt.move(0,1)
          when ?q
            win.close
            Curses.close_screen
            break
          end
        end
      end
    end
  end
  class Globals
    HEIGHT = 10
    attr_reader :window
    def initialize(parent_window)
      @window = parent_window.subwin(HEIGHT, WIDTH, 0, 0) 
      TextWithValue.new(window, 'TESTING', 'VALUE', COLOR_GREEN, 20, 0, 0)
      window.refresh
    end
  end
  class Str
    HEIGHT = 16
    attr_reader :window
    TOP = Globals::HEIGHT
    def initialize(parent_window)
      @window = parent_window.subwin(HEIGHT, WIDTH, 0, 0)
    end
  end
  class CC
    HEIGHT = Curses.lines - Globals::HEIGHT - Str::HEIGHT
    TOP = Str::HEIGHT + Globals::HEIGHT
    def initialize(parent_window)
    end
  end
  class TextWithValue
    attr_reader :text, :value, :window, :color
    def initialize(parent_window, text, value, color, width, top, left)
      @color = color
      @window = parent_window.subwin(1, width, top, left)
      @window.attron(Curses.color_pair(color)|Curses::A_NORMAL) {
        @window << "#{text}: #{value}"
      }
    end
    private
      def value=(value)
        @window.clear
        @window.attron(Curses.color_pair(color)|Curses::A_NORMAL) {
          @window << "#{text}: #{value}"
        }
      end
  end
  class TextRow
    attr_reader :windows, :color
    def initialize(parent_window, values, color, top)
      @color = color
      @windows = values.reduce([]) do|ws, v|
                   w = parent_window.subwin(1, WIDTH, top, 0)
                   w.attron(Curses.color_pair(color)|Curses::A_NORMAL) {w << v}
                   ws << w
                 end
    end
    private
      def row=(values)
        @windows.each do |w|
          w.clear
          w.attron(Curses.color_pair(color)|Curses::A_NORMAL) {w << v.shift}
        end
      end
  end
  class Title
    def initialize(parent_window, title)

    end
  end
end

