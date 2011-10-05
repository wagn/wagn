# Load profile environment
env = ENV["Rails.env"] = "profile"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")

# Load Rails testing infrastructure
require 'test_help'

# Now we can load test_helper since we've already loaded the
# profile RAILS environment.
require File.expand_path('test_helper', File.dirname(__FILE__)))

# Reset the current environment back to profile
# since test_helper reset it to test
ENV["Rails.env"] = env

# Now load ruby-prof and away we go
require 'ruby-prof'

# Setup output directory to Rails tmp directory
RubyProf::Test::PROFILE_OPTIONS[:output_dir] = 
    File.expand_path(File.join(Rails.root, 'tmp', 'profile'))
