module Zgomot::UI
  WIDTH = 80
  class Window
    class << self
      def dash
        Curses.noecho
        Curses.init_screen
        Curses.start_color
        Curses.curs_set(0)
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
      window << 'TESTING'
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
    def initialize(window, value, width)
    end
  end
end

