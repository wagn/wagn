require_relative '../../spec_helper'

describe Wagn::Set::Type::Pointer do
  before do
    User.current_user = :joe_user
  end
  
  context "item_names" do
    p = Card.new(:name=>'foo', :type=>'Pointer', :content=>"[[Busy]]\n[[Body]]")
    names = p.item_names
    names.should == ['Busy', 'Body']
  end
  
  context "add_item" do
    it "add to empty ref list" do
      @pointer = Card.new :name=>"tp", :type=>"pointer", :content=>""
      @pointer.add_item "John"
      assert_equal "[[John]]", @pointer.content
    end

    it "add to existing ref list" do
      @pointer = Card.new :name=>"tp", :type=>"pointer", :content=>"[[Jane]]"
      @pointer.add_item "John"
      assert_equal "[[Jane]]\n[[John]]", @pointer.content
    end
    
    it "not add duplicate entries" do
      @pointer = Card.new :name=>"tp", :type=>"pointer", :content=>"[[Jane]]"
      @pointer.add_item "Jane"
      assert_equal "[[Jane]]", @pointer.content
    end
  end       
  
  context "drop_item" do
    it "remove the link" do
      Rails.logger.info "testing point 0"
      @pointer = Card.new :name=>"tp", :type=>"pointer", :content=>"[[Jane]]\n[[John]]"
      Rails.logger.info "testing point 1 #{@pointer.inspect}"
      @pointer.drop_item "Jane" 
      Rails.logger.info "testing point 2 #{@pointer.inspect}"
      assert_equal "[[John]]", @pointer.content
    end                                
    
    it "not fail on non-existent reference" do
      @pointer = Card.new :name=>"tp", :type=>"pointer", :content=>"[[Jane]]\n[[John]]"
      @pointer.drop_item "Bigfoot" 
      assert_equal "[[Jane]]\n[[John]]", @pointer.content
    end

    it "remove the last link" do
      @pointer = Card.new :name=>"tp", :type=>"pointer", :content=>"[[Jane]]"
      @pointer.drop_item "Jane"
      assert_equal "", @pointer.content
    end
  end
     
  context "watching" do
    it "not break on permissions" do
      watchers = Card.fetch_or_new "Home+*watchers"
      watchers.typecode.should == 'Pointer'
      watchers.add_item User.current_user.card.name
      assert_equal '[[Joe User]]', watchers.content
    end
  end
end
