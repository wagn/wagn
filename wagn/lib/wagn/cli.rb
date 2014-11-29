require 'rbconfig'
require 'wagn/script_wagn_loader'
warn "wagn/cli noclas " unless Module.constants.include? :Card
warn "wagn/cli :Card class: #{Card.class}" if Module.constants.include? :Card

# If we are inside a Wagn application this method performs an exec and thus
# the rest of this script is not run.
Wagn::ScriptWagnLoader.exec_script_wagn!

require 'rails/ruby_version_check'
Signal.trap("INT") { puts; exit(1) }

#if ARGV.first == 'plugin'
#  ARGV.shift
#  require 'wagn/commands/plugin_new'
#else

warn "wagn/cli1 noclas " unless Module.constants.include? :Card
warn "wagn/cli1 :Card class: #{Card.class}" if Module.constants.include? :Card
require 'wagn/commands/application'
warn "wagn/cli2 noclas " unless Module.constants.include? :Card
warn "wagn/cli2 :Card class: #{Card.class}" if Module.constants.include? :Card
#end
