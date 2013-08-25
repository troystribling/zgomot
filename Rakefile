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
    gem.license = 'MIT'
    gem.files.include %w(lib/jeweler/templates/.gitignore VERSION)
    gem.add_dependency('ffi', '~> 1.0.9')
    gem.add_dependency('rainbow', '~> 1.1.4')
    gem.add_dependency('pry', '~> 0.9.12.2')
    gem.add_dependency('fssm', '~> 0.2.10')
  end
rescue LoadError
  abort "jeweler is not available. In order to run test, you must: sudo gem install technicalpickles-jeweler --source=http://gems.github.com"
end

