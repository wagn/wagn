require File.expand_path('../profile_test_helper', File.dirname(__FILE__))

describe "Render", ActiveSupport::TestCase do
  include RubyProf::Test

  it "render" do
    Wagn::Renderer.new( Card.new( :name => "hi", :content => "{{+plus1}} {{+plus2}} {{+plus3}}" )).render :core
  end
end
