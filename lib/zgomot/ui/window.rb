module Zgomot::UI
  WIDTH = 80
  class Window
    class << self
      def init_curses
        Curses.noecho
        Curses.init_screen
        Curses.start_color
        Curses.curs_set(0)
        Curses.init_pair(Curses::COLOR_GREEN,Curses::COLOR_GREEN,Curses::COLOR_BLACK)
        Curses.init_pair(Curses::COLOR_WHITE,Curses::COLOR_WHITE,Curses::COLOR_BLACK)
        Curses.init_pair(Curses::COLOR_YELLOW,Curses::COLOR_YELLOW,Curses::COLOR_BLACK)
        Curses.init_pair(Curses::COLOR_CYAN,Curses::COLOR_CYAN,Curses::COLOR_BLACK)
        Curses.init_pair(Curses::COLOR_RED,Curses::COLOR_RED,Curses::COLOR_BLACK)
        Curses.init_pair(Curses::COLOR_MAGENTA,Curses::COLOR_MAGENTA,Curses::COLOR_BLACK)
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
      TextWithValue.new(window, 'TESTING', 'VALUE', Curses::COLOR_GREEN, 20, 0, 0)
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
    attr_reader :text, :value, :window
    def initialize(parent_window, text, value, color, width, top, left)
      @window = parent_window.subwin(1, width, top, left)
      @window.attron(Curses.color_pair(color)|Curses::A_NORMAL) {
        @window << "#{text}: #{value}"
      }
    end
    def value=(value)
      @window.clear
      @window.attron(Curses.color_pair(color)|Curses::A_NORMAL) {
        @window << "#{text}: #{value}"
      }
    end
  end
  class TextRow
    attr_accessor :windows
    def initialize(parent_window, values, color, top)
      @windows = values.reduce([]) do|ws, v|
                   w = parent_window.subwin(1, WIDTH, top, 0)
                   w.attron(Curses.color_pair(color)|Curses::A_NORMAL) {w << v}
                   ws << w
                 end
    end
    def row=(values)
    end
  end
  class Title
    def initialize(title)

    end
  end
end

