require 'rubygems'
require "#{File.dirname(__FILE__)}/../lib/zgomot"

#.........................................................................................................
before_start do
  Zgomot.logger.level = Logger::DEBUG
  Zgomot.logger.info "before_start"
  puts "#{Zgomot.config.inspect}"
end

#.........................................................................................................
str 'simple' do
  
end