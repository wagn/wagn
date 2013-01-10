require File.expand_path('../profile_test_helper', File.dirname(__FILE__))

describe "Topic", ActionController::IntegrationTest do
  include RubyProf::Test

  it "topic" do
    get '/Arts_education'
  end
end
