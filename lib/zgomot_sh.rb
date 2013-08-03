require 'rubygems'
require 'zgomot'
Zgomot.live = true
begin
  load ENV['HOME'] + '/.zgomot'
rescue LoadError; end
Zgomot::Boot.boot
Pry.config.prompt_name = "\e[38;5;199mzgomot\e[0m\002"
