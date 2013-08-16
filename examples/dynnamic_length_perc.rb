require 'rubygems'
require "#{File.dirname(__FILE__)}/../lib/zgomot"

before_start do
  Zgomot.logger.level = Logger::DEBUG
end

if sources.include?("nanoKONTROL")
  add_input("nanoKONTROL")
  add_cc(:mult, 17, :type => :cont, :min => 0, :max => 4, :init => 0)
  len = 4
  str 'perce', [pr(:low_floor_tom, :l => len),
                 pr(:low_tom, :l => len),
                 n(:R, :l=> len),
                 pr(:high_mid_tom, :l => len)], :ch=>0 do |pattern|
    pattern.length = (2**cc(:mult).to_i)*len
    pattern
  end
  play
end



