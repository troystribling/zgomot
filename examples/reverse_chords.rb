require 'rubygems'
require "#{File.dirname(__FILE__)}/../lib/zgomot"

before_start do
  Zgomot.logger.level = Logger::DEBUG
end

str 'chords', [c(:C,:min).arp!(4), c(:C,:min).arp!(4).rev!, c(:E,:min).arp!(4), c(:E,:min).arp!(4).rev!], :lim=>3 do |pattern|
  pattern
end

play
