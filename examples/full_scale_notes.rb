require 'rubygems'
require "#{File.dirname(__FILE__)}/../lib/zgomot"

before_start do
  Zgomot.logger.level = Logger::DEBUG
end

str 'full_scale', np(nil,5), :lim=>6 do |pattern|
   pattern.tonic!([:A, count])
end

play
