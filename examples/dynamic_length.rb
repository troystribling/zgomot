require 'rubygems'
require "#{File.dirname(__FILE__)}/../lib/zgomot"

before_start do
  Zgomot.logger.level = Logger::DEBUG
end

if sources.include?("nanoKONTROL")
  add_input("nanoKONTROL")
  add_cc(:mult, 17, :type => :cont, :min => 1, :max => 3, :init => 0)
  len = 4
  str 'simple_input', np([:A,4],2,:l=>len)[7,5,3,1] do |pattern|
    pattern.length = (2**cc(:mult).to_i)*len
    pattern
  end
  play
end


