require File.expand_path('../profile_test_helper', File.dirname(__FILE__))

describe "Homepage", ActionController::IntegrationTest do
  include RubyProf::Test

  # Replace this with your real tests.
  it "homepage" do
    get '/Home'
  end
end
