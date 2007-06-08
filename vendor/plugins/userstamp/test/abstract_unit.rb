require 'test/unit'
require 'rubygems'
require_gem 'activesupport'
require_gem 'activerecord'
require 'connection'
require 'active_record/fixtures'

RAILS_ROOT = File.dirname(__FILE__)

$: << "../lib"

require 'userstamp.rb'

class ActiveRecord::Base
    include ActiveRecord::Userstamp
end


class Test::Unit::TestCase
  self.fixture_path = File.dirname(__FILE__) + "/fixtures/"
end