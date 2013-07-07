require 'rubygems'
require 'zgomot'
Zgomot.live = true
begin
  load ENV['HOME'] + '/.zgomot'
rescue LoadError; end
Zgomot::Boot.boot
