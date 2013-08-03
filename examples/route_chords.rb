require 'rubygems'
require "#{File.dirname(__FILE__)}/../lib/zgomot"

before_start do
  Zgomot.logger.level = Logger::DEBUG
end

chords = cp([:B,3],:ionian,:l=>4)[1,4,5,5]

str 'note-0', chords.note(0), :ch=>0 do |pattern|
  pattern
end

str 'note-1', chords.note(1), :ch=>1 do |pattern|
  pattern
end

str 'note-2', chords.note(2), :ch=>2 do |pattern|
  pattern
end

run
