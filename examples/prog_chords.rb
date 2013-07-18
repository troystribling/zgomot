require 'rubygems'
require "#{File.dirname(__FILE__)}/../lib/zgomot"

before_start do
  Zgomot.logger.level = Logger::DEBUG
end

str 'prog', cp([:B,3],:ionian,:l=>4)[1,4,5,5], :lim=>6 do |pattern|
  ch << pattern
end

play
