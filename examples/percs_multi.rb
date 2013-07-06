require 'rubygems'
require "#{File.dirname(__FILE__)}/../lib/zgomot"

before_start do
  Zgomot.logger.level = Logger::DEBUG
end

score = [pr([:acoustic_bass_drum, :cowbell]), pr(:R), pr([:acoustic_snare, :hand_clap]), pr(:R)]

str 'percussion', score, :lim=>:inf do |pattern|
  ch(2) << pattern
end

play
