require 'rubygems'
require "#{File.dirname(__FILE__)}/../lib/zgomot"

before_start do
  Zgomot.logger.level = Logger::DEBUG
end

str 'inversion', cp([:C,3],:ionian,:l=>4).inv!(2), :lim=>1 do |pattern|
  ch << pattern
end

play
