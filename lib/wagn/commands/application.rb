require 'rails/generators'
require '../../../generators/wagn_generator'

if ARGV.first != "new"
  ARGV[0] = "--help"
else
  ARGV.shift
end

WagnGenerator.start