require 'rubygems'
require "#{File.dirname(__FILE__)}/../lib/zgomot"

#.........................................................................................................
before_start do
  Zgomot.logger.level = Logger::DEBUG
  puts "#{Zgomot.config.inspect}"
end

score = [n(:C,5), n(:B), n(:R), n(:G), n(:C,4,2), n(:E,5,2)]
#.........................................................................................................
str 'simple', score do |clock, pattern|
  ch + pattern
end

#.........................................................................................................
play