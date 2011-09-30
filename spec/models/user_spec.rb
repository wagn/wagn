require File.dirname(__FILE__) + '/../spec_helper'

describe "User" do
  describe "#read_rule_ids" do
    before(:all) do
      @read_rule_ids = User.as(:joe_user) { User.as_user.read_rule_ids }
    end

    
    it "*all+*read should apply to Joe User" do
      @read_rule_ids.member?(Card.fetch('*all+*read').id).should be_true
    end
    
    it "3 more should apply to Joe Admin" do
      User.as(:joe_admin) do
        User.as_user.read_rule_ids.length.should == @read_rule_ids.size+3
      end
    end
    
  end
end
