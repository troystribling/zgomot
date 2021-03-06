require 'rubygems'
require "#{File.dirname(__FILE__)}/../lib/zgomot"

before_start do
  Zgomot.logger.level = Logger::DEBUG
end

str 'modes', [np([:A,4],nil,:l=>8), np([:A,4],nil,:l=>8).reverse!.shift, n(:R)], :lim=>7 do |pattern|
  Zgomot.logger.info "TONIC: [A,4], MODE: #{count-1}"
  pattern.mode!(count)
end

play
