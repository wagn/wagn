require File.expand_path('../profile_test_helper', File.dirname(__FILE__))

describe "Fetch", ActiveSupport::TestCase do
  include RubyProf::Test

  it "fetch" do
    Card.fetch("Arts education")
  end
end