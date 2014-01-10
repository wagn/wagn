require 'wagn'

APP_PATH = File.expand_path "#{Wagn.gem_root}/config/application"
require File.expand_path( "#{Wagn.gem_root}/config/boot" )
require 'rails/commands'
