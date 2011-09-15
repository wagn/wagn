require_relative '../profile_test_helper'

describe "Homepage", ActionController::IntegrationTest do    
  include RubyProf::Test
  
  # Replace this with your real tests.
  it "homepage" do
    get '/Home'
  end
end
