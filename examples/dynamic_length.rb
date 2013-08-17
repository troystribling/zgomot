require 'rubygems'
require "#{File.dirname(__FILE__)}/../lib/zgomot"

before_start do
  Zgomot.logger.level = Logger::DEBUG
end

if sources.include?("nanoKONTROL")
  add_input("nanoKONTROL")
  add_cc(:mult, 33, :type => :cont, :min => 0, :max => 3, :init => 0)
  len = 4
  str 'dynamic', np([:A,4],2,:l=>len)[7,5,3,1] do |pattern|
    pattern.length!((2**cc(:mult).to_i)*len)
  end
  play
end


