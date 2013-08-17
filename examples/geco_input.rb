require 'rubygems'
require "#{File.dirname(__FILE__)}/../lib/zgomot"

before_start do
  Zgomot.logger.level = Logger::DEBUG
end

if sources.include?("GECO")
  add_input("GECO")
  add_cc(:mode, 17, :type => :cont, :min => 0, :max => 6, :init => 0)
  str 'simple_input', np([:A,4],2,:l=>4)[7,5,3,1] do |pattern|
    pattern.mode!(cc(:mode).to_i)
  end
  play
end

