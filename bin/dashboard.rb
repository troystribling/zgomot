#!/usr/bin/ruby
require 'curses'

Curses.init_screen()

my_str = "LOOK! PONIES!"
win = Curses::Window.new( 8, (my_str.length + 10),
                          (Curses.lines - 8) / 2,
                          (Curses.cols - (my_str.length + 10)) / 2 )
win.box("|", "-")
win.setpos(2,3)
win.addstr(my_str)
# or even
win << "\nORLY"
win << "\nYES!! " + my_str
win.refresh
win.getch
win.close
