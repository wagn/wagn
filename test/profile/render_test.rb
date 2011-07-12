require File.dirname(__FILE__) + '/../profile_test_helper'

describe "Render", ActiveSupport::TestCase do
  include RubyProf::Test
  
  it "render" do
    Wagn::Renderer.new( Card.new( :name => "hi", :content => "{{+plus1}} {{+plus2}} {{+plus3}}" )).render :naked
  end
end
