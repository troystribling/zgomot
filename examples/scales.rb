require 'rubygems'
require "#{File.dirname(__FILE__)}/../lib/zgomot"

#.........................................................................................................
before_start do
  Zgomot.logger.level = Logger::DEBUG
end

#.........................................................................................................
str 'scales', [k([:A,3],:locrian,4)], :lim=>3 do |time, pattern|
  ch + pattern
end

#.........................................................................................................
play
