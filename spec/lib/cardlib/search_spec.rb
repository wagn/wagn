require File.dirname(__FILE__) + '/../../spec_helper'

A_JOINEES = ["B", "C", "D", "E", "F"]

describe Cardlib::Search do
  describe ".find_builtin" do
    it "should retrieve cards added by add_builtin" do
      Card.add_builtin( Card.new(:name=>"*ghost", :content=>"X"))
      Card.builtin_virtual('*ghost').should be_instance_of(Card::Basic)
      Card.builtin_virtual('*ghost').content.should == "X"
    end

    ['*head','*foot','*alerts','*navbox','*version','*account links'].each do |name|
      it "should retrieve standard builtin card #{name}" do
        card = Card.builtin_virtual(name)
        card.should be_instance_of(Card::Basic)
        card.should be_builtin
      end
    end
  end
  
  describe ".find_virtual" do
    before { User.as :joe_user }

    it "should find cards with *right+*content specified" do
      Card::Search.create! :name=>"testsearch+*right+*content", :content=>'{"plus":"_self"}', :type => 'Search'
      c = Card.find_virtual("A+testsearch")
      c.type.should == 'Search'
      c.content.should ==  "{\"plus\":\"_self\"}"
    end
  end
end

