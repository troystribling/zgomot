require 'rubygems'
require "#{File.dirname(__FILE__)}/../lib/zgomot"

before_start do
  Zgomot.logger.level = Logger::DEBUG
end

str 'melody-1', np([:B,3],nil,:l=>4)[1,4,5,5], :lim=>:inf, :ch => 0 do |pattern|
  pattern.mode!((count/4) % 7 + 1)
end

str 'melody-2', np([:B,3],:ionian,:l=>4)[1,4,5,5].bpm!(16.0/15.0), :lim=>:inf, :ch => 1  do |pattern|
  pattern
end

play
