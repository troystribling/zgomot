$:.unshift(File.dirname(__FILE__))

require 'optparse'
require 'forwardable'
require 'logger'
require 'thread'
require 'yaml'
require 'monitor'
require 'ffi'
require 'rainbow'
require 'curses'

require 'zgomot/config'
require 'zgomot/boot'
require 'zgomot/patches'
require 'zgomot/comp'
require 'zgomot/midi'
require 'zgomot/drivers'
require 'zgomot/ui'
require 'zgomot/main'

