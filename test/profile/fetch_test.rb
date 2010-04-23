require File.dirname(__FILE__) + '/../profile_test_helper'

describe "Fetch", ActiveSupport::TestCase do
  include RubyProf::Test
  
  it "fetch" do
    Card.fetch("Arts education")
  end
end