require 'rubygems'
require "#{File.dirname(__FILE__)}/../lib/zgomot"

before_start do
  Zgomot.logger.level = Logger::DEBUG
end

str 'notes' do
  [nl(n([:C,5]), n(:B)), nl(n(:G), n(:C,))]
end

play
