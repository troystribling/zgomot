require 'rubygems'
require "#{File.dirname(__FILE__)}/../lib/zgomot"

before_start do
  Zgomot.logger.level = Logger::DEBUG
end

str 'arp', cp([:B,3],:ionian,:l=>4)[1,4,5,5].arp!(16), :lim=>1 do |pattern|
  pattern
end

play
