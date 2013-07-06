require 'rubygems'
require "#{File.dirname(__FILE__)}/../lib/zgomot"

before_start do
  Zgomot.logger.level = Logger::DEBUG
end

str 'notes' do
  (ch << [n([:C,5]), n(:B), n(:G), n(:C,:l=>2), n([:E,5],:l=>1)]).each do |note|
    note.length = 2**(note.time.beat + 2)
  end
end

play
