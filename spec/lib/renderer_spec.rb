require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Renderer do
  before do
    User.current_user = :wagbot
  end
  
  it "replace references should work on inclusions inside links" do       
    card = Card.create!(:name=>"test", :content=>"[[test{{test}}]]"  )    
    assert_equal "[[test{{best}}]]", Renderer.new(card).replace_references("test", "best" )
  end                                                                                                
end
