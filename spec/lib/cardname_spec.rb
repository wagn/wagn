require File.dirname(__FILE__) + '/../spec_helper'

describe Cardname, "to_key" do
  it "should remove spaces" do
    "This Name".to_key.should == "this_name"
  end
end