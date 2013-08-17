require 'rubygems'
require "#{File.dirname(__FILE__)}/../lib/zgomot"

before_start do
  Zgomot.logger.level = Logger::DEBUG
end

str 'cycle', [nl(n([:C,5]), n(:B)), nl(n(:G), n(:C,))] do |pattern|
  notes = pattern.shift
  pattern.map{|n| n.push(notes.shift)}
end

play

