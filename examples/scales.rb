require 'rubygems'
require "#{File.dirname(__FILE__)}/../lib/zgomot"

#.........................................................................................................
before_start do
  Zgomot.logger.level = Logger::DEBUG
end

#.........................................................................................................
pclass = [:C, :Cs, :D, :Ds, :E, :F, :Fs, :G, :Gs, :A, :As, :B]

#.........................................................................................................
str 'scale', [k(nil,:dorian,4), k(nil,:dorian,4).reverse!.shift, n(:R)], :lim=>pclass.length do |time, pattern|
  Zgomot.logger.info "TONIC: [#{pclass[count-1]},4], MODE: dorian"
  ch << pattern.tonic!([pclass[count-1], 4])
end

#.........................................................................................................
play
