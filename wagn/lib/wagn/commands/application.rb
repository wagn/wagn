require "rails/generators"
require File.expand_path("../../generators/wagn/wagn_generator", __FILE__)

if ARGV.first != "new"
  ARGV[0] = "--help"
else
  ARGV.shift
end

WagnGenerator.start
