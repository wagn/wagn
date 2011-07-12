require File.dirname(__FILE__) + '/../spec_helper'

describe "User" do
  describe "#read_rule_ids" do

    it "one should apply to Joe User" do
      User.as(:joe_user) do
        User.as_user.read_rule_ids.should == [Card.fetch('*all+*read').id]
      end
    end
    
    it "3 should apply to Wagn Bot" do
      User.as(:wagbot) do
        User.as_user.read_rule_ids.length.should == 3
      end
    end
    
  end
end