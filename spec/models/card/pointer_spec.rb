require File.dirname(__FILE__) + '/../../spec_helper'

describe Card::Pointer do
  before do
    User.as :joe_user
  end
  
  context "add_reference" do
    it "add to empty ref list" do
      @pointer = Card.new :name=>"tp", :type=>"pointer", :content=>""
      @pointer.add_reference "John"
      assert_equal "[[John]]", @pointer.content
    end

    it "add to existing ref list" do
      @pointer = Card.new :name=>"tp", :type=>"pointer", :content=>"[[Jane]]"
      @pointer.add_reference "John"
      assert_equal "[[Jane]]\n[[John]]", @pointer.content
    end
    
    it "not add duplicate entries" do
      @pointer = Card.new :name=>"tp", :type=>"pointer", :content=>"[[Jane]]"
      @pointer.add_reference "Jane"
      assert_equal "[[Jane]]", @pointer.content
    end
  end       
  
  context "remove_reference" do
    it "remove the link" do
      @pointer = Card.new :name=>"tp", :type=>"pointer", :content=>"[[Jane]]\n[[John]]"
      @pointer.remove_reference "Jane" 
      assert_equal "[[John]]", @pointer.content
    end                                
    
    it "not fail on non-existent reference" do
      @pointer = Card.new :name=>"tp", :type=>"pointer", :content=>"[[Jane]]\n[[John]]"
      @pointer.remove_reference "Bigfoot" 
      assert_equal "[[Jane]]\n[[John]]", @pointer.content
    end

    it "remove the last link" do
      @pointer = Card.new :name=>"tp", :type=>"pointer", :content=>"[[Jane]]"
      @pointer.remove_reference "Jane"
      assert_equal "", @pointer.content
    end
  end
     
  context "watching" do
    it "not break on permissions" do
      watchers = Card.find_or_new( :name => "Home+*watchers" )
      watchers.add_reference User.current_user.card.name
      assert_equal '[[Joe User]]', watchers.content
    end
  end
end
