require 'rubygems'
require "#{File.dirname(__FILE__)}/../lib/zgomot"

before_start do
  Zgomot.logger.level = Logger::DEBUG
end

if sources.include?("nanoKONTROL")
  add_input("nanoKONTROL")
  add_cc(:mode, 17, :type => :cont, :min => 0, :max => 6, :init => 0)
  add_cc(:reverse, 13, :type => :switch)
  add_cc(:turn_off, 12, :type => :switch)
  add_cc(:turn_off, 12, :type => :switch) do
    tog(:simple_input)
  end
  str 'simple_input', np([:A,4],2,:l=>4)[7,5,3,1] do |pattern|
    if cc(:reverse)
      pattern.mode!(mode.to_i).reverse!
    else
      pattern.mode!(mode.to_i)
    end
  end
  play
end

