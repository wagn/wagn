require "rbconfig"
require "wagn/script_wagn_loader"

# If we are inside a Wagn application this method performs an exec and thus
# the rest of this script is not run.
Wagn::ScriptWagnLoader.exec_script_wagn!

require "rails/ruby_version_check"
Signal.trap("INT") { puts; exit(1) }

# if ARGV.first == 'plugin'
#  ARGV.shift
#  require 'wagn/commands/plugin_new'
# else

require "wagn/commands/application"
# end
