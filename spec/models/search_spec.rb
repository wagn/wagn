require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../../test/helpers/wagn_test_helper'

include WagnTestHelper

describe Cardlib::Search, "find_builtin" do
  it "should retrieve cards added by add_builtin" do
    Card.add_builtin( Card.new(:name=>"*ghost", :content=>"X"))
    Card.find_builtin('*ghost').should be_instance_of(Card::Basic)
    Card.find_builtin('*ghost').content.should == "X"
  end

  it "should retrieve standard builtin cards" do
    ['*head','*foot','*alerts','*navbox','*version','*account links'].each do |name|
      card = Card.find_builtin(name)
      card.should be_instance_of(Card::Basic)
      card.should be_builtin
    end
  end
end


describe Card::Search, "pattern key generation" do
  it "should store a relative pattern key" do
    User.as :wagbot
    Card.create!(:name=>"*on right+*rform", :type=>'Set', :content=>'{"right":"_left"}')
    c = Card.create!(:name=>"test+*on right")
    c.pattern_spec_key.should=="RightName:test"
  end
end