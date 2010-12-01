$:.unshift('lib')
require 'rubygems'
require 'rake'

#####-------------------------------------------------------------------------------------------------------
task :default => :test

#####-------------------------------------------------------------------------------------------------------
begin
require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "zgomot"
    gem.summary = %Q{zgomot is a simple DSL for writting MIDI music.}
    gem.email = "troy.stribling@gmail.com"
    gem.homepage = "http://github.com/troystribling/zgomot"
    gem.authors = ["Troy Stribling"]
    gem.files.include %w(lib/jeweler/templates/.gitignore VERSION)
    gem.add_dependency('midiator',    '>= 0.3.3')
  end
rescue LoadError
  abort "jeweler is not available. In order to run test, you must: sudo gem install technicalpickles-jeweler --source=http://gems.github.com"
end

