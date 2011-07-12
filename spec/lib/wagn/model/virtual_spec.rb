require File.dirname(__FILE__) + '/../../../spec_helper'

#A_JOINEES = ["B", "C", "D", "E", "F"]

describe Wagn::Model::Virtual do  
  describe ".find_virtual" do
    before { User.as :joe_user }

    it "should find cards with *right+*content specified" do
      Card.create! :name=>"testsearch+*right+*content", :content=>'{"plus":"_self"}', :type => 'Search'
      c = Card.find_virtual("A+testsearch")
      c.typecode.should == 'Search'
      c.content.should ==  "{\"plus\":\"_self\"}"
    end
  end
end

