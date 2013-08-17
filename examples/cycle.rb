require 'rubygems'
require "#{File.dirname(__FILE__)}/../lib/zgomot"

before_start do
  Zgomot.logger.level = Logger::DEBUG
end

str 'cycle', np([:Fs, 4], :dorian, :l=>4)[3,1,3,5] do |pattern|
  pattern.push(pattern.shift.first)
end

play

