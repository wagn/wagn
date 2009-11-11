require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Card do
  before do
    User.as(:wagbot)
  end
  
  it "stores and retrieves settings" do
    a = Card["A"]
    a.setting "speed", "fast"
    a.save
    Card["A"].setting("speed").should == "fast"
  end
end