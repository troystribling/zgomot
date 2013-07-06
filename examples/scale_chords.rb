require 'rubygems'
require "#{File.dirname(__FILE__)}/../lib/zgomot"

before_start do
  Zgomot.logger.level = Logger::DEBUG
end

str 'scale', cp([:C,4],:ionian,:l=>4), :lim=>1 do |pattern|
  ch << pattern
end

play
