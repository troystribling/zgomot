require 'rubygems'
require "#{File.dirname(__FILE__)}/../lib/zgomot"

before_start do
  Zgomot.logger.level = Logger::DEBUG
end

score = [pr(:acoustic_bass_drum), pr(:bass_drum_1), pr(:acoustic_snare), pr(:electric_snare),
         pr(:open_hi_hat), pr(:closed_hi_hat), pr(:high_tom), pr(:low_mid_tom),
         pr(:low_tom), pr(:hand_clap), pr(:ride_cymbal_1), pr(:cowbell)]

str 'percussion', score, :lim=>:inf do |pattern|
  ch(2) << pattern
end

play
