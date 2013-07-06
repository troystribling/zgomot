require 'rubygems'
require "#{File.dirname(__FILE__)}/../lib/zgomot"

before_start do
  Zgomot.logger.level = Logger::DEBUG
end

str 'notes' do
  (ch << [n([:C,5]), n(:B), n(:R), n(:G), n(:C,:l=>2), n([:E,5],:l=>2)]).each do |note|
    note.velocity = 0.2*note.time.beat + 0.2
  end
end

play
