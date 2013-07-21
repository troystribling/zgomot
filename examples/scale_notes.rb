require 'rubygems'
require "#{File.dirname(__FILE__)}/../lib/zgomot"

before_start do
  Zgomot.logger.level = Logger::DEBUG
end

str 'scale', [np([:C,4],:dorian,:l=>4), np([:C,4],:dorian,:l=>4).reverse!.shift, n(:R)], :lim=>3 do |pattern|
  pattern
end

play
