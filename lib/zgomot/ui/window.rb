module Zgomot::UI
  WIDTH = 80
  class Window
    class << self
      def init_curses
        Curses.noecho
        Curses.init_screen
        Curses.start_color
        Curses.init_pair(Curses::COLOR_GREEN,Curses::COLOR_GREEN,Curses::COLOR_BLACK)
        Curses.init_pair(Curses::COLOR_WHITE,Curses::COLOR_WHITE,Curses::COLOR_BLACK)
        Curses.init_pair(Curses::COLOR_YELLOW,Curses::COLOR_YELLOW,Curses::COLOR_BLACK)
        Curses.init_pair(Curses::COLOR_CYAN,Curses::COLOR_CYAN,Curses::COLOR_BLACK)
        Curses.init_pair(Curses::COLOR_RED,Curses::COLOR_RED,Curses::COLOR_BLACK)
        Curses.init_pair(Curses::COLOR_MAGENTA,Curses::COLOR_MAGENTA,Curses::COLOR_BLACK)
        Curses.curs_set(0)
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
      Text.new(window, 'TESTING', Curses::COLOR_GREEN, 20, 0, 0)
      Text.new(window, 'TESTING2', Curses::COLOR_CYAN, 20, 1, 0)
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
  class Text
    attr_accessor :window
    def initialize(parent_window, value, color, width, top, left)
      @window = parent_window.subwin(1, width, top, left)
      window.attron(Curses.color_pair(color)|Curses::A_NORMAL) {
        window << value
      }
    end
  end
end

