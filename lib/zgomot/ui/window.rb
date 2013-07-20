module Zgomot::UI
  class Window
    class << self
      def dash
        Curses.init_screen
        my_str = "ZGOMOT"
        win = Curses::Window.new(8, (my_str.length + 10), (Curses.lines - 8)/2, (Curses.cols - (my_str.length + 10))/2)
        win.box(?|, ?-)
        win.setpos(2,3)
        win.addstr(my_str)
        win.refresh
        win.getch
        win.close
        Curses.close_screen
      end
    end
  end
end

