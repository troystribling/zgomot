require 'rubygems'
require "#{File.dirname(__FILE__)}/../lib/zgomot"

before_start do
  Zgomot.logger.level = Logger::DEBUG
end

major_modes = [:ionian, :lydian, :mixolydian]
minor_modes = [:dorian, :phrygian, :aeolian]

m_slow = mark
m_slow.add([0.6, 0.4]) do |count|
  np([:A,4],major_modes[count % 3],:l=>4)[7,5,3,1]
end
m_slow.add([0.4, 0.6]) do |count|
  np([:A,4],minor_modes[count % 3],:l=>4)[7,5,3,1]
end

str :slow do
  ch(0) << m_slow.next(count)
end

m_fast = mark
m_fast.add([0.6, 0.4]) do |count|
  np([:G,4],major_modes[count % 3],:l=>4)[7,5,3,1].bpm!(16.0/15.0)
end
m_fast.add([0.4, 0.6]) do |count|
  np([:G,4],minor_modes[count % 3],:l=>4)[7,5,3,1].bpm!(16.0/15.0)
end

str :fast do
  ch(1) << m_fast.next(count)
end

str :perc do
  ch(2) << if (count % 2).eql?(0)
             [pr(:R, :l=>2), pr(:hand_clap), pr(:hand_clap)]
           else
             pr(:R,:l=>1)
           end
end

play
