require 'rubygems'
require "#{File.dirname(__FILE__)}/../lib/zgomot"

before_start do
  Zgomot.logger.level = Logger::DEBUG
end

str 'chords', [ c(:C), c(:E,:min), c(:D,:min), c(:B,:dim), c(:G,:maj)], :lim=>3 do |pattern|
  pattern
end

play
