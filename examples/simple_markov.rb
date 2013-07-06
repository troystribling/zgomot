require 'rubygems'
require "#{File.dirname(__FILE__)}/../lib/zgomot"

before_start do
  Zgomot.logger.level = Logger::DEBUG
end

m = mark
m.add([0.6, 0.4]) do
  np([:A,4],:dorian,:l=>4)[7,5,3,1,]
end
m.add([0.4, 0.6]) do
  np([:A,4],:ionian,:l=>4)[7,5,3,1]
end

str 'markov' do
  ch << m.next
end

play
