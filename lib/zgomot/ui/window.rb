module Zgomot::UI
  WIDTH = 80
  class Window
    class << self
      def dash
        Curses.noecho
        Curses.init_screen
        win = Curses::Window.new(0, WIDTH, 0, 0)
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
    class << self
      def window
      end
    end
  end
  class Str
    HEIGHT = (Curses.lines - Globals::HEIGHT)/2
    TOP = Globals::HEIGHT
    class << self
      def window
      end
    end
  end
  class CC
    HEIGHT = (Curses.lines - Globals::HEIGHT)/2
    TOP = Str::HEIGHT + Globals::HEIGHT
    class << self
      def window
      end
    end
  end
  class Text
  end
end

