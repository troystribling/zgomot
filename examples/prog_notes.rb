require 'rubygems'
require "#{File.dirname(__FILE__)}/../lib/zgomot"

before_start do
  Zgomot.logger.level = Logger::DEBUG
end

str 'prog', np([:A,4],nil,:l=>4)[7,5,3,1], :lim=>6 do |pattern|
  ch << pattern.mode!(count)
end

play
