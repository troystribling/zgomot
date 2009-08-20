$:.unshift(File.dirname(__FILE__))

require 'optparse'
require 'logger'
require 'monitor'

require 'midiator'

require 'zgomot/config'
require 'zgomot/boot'
require 'zgomot/patches'
require 'zgomot/comp'
require 'zgomot/midi'
require 'zgomot/main'
