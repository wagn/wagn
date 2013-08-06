# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card::Set::Type::Pointer do
  describe "item_names" do
    it "should return array of names of items referred to by a pointer" do
      Card.new(:type=>'Pointer', :content=>"[[Busy]]\n[[Body]]").item_names.should == ['Busy', 'Body']
    end
  end

  describe "add_item" do
    it "add to empty ref list" do
      pointer = Card.new :name=>"tp", :type=>"pointer", :content=>""
      pointer.add_item "John"
      pointer.content.should == "[[John]]"
    end

    it "add to existing ref list" do
      pointer = Card.new :name=>"tp", :type=>"pointer", :content=>"[[Jane]]"
      pointer.add_item "John"
      pointer.content.should == "[[Jane]]\n[[John]]"
    end

    it "not add duplicate entries" do
      pointer = Card.new :name=>"tp", :type=>"pointer", :content=>"[[Jane]]"
      pointer.add_item "Jane"
      pointer.content.should == "[[Jane]]"
    end
  end

  describe "drop_item" do
    it "remove the link" do
      pointer = Card.new :name=>"tp", :type=>"pointer", :content=>"[[Jane]]\n[[John]]"
      pointer.drop_item "Jane"
      pointer.content.should == "[[John]]"
    end

    it "not fail on non-existent reference" do
      pointer = Card.new :name=>"tp", :type=>"pointer", :content=>"[[Jane]]\n[[John]]"
      pointer.drop_item "Bigfoot"
      pointer.content.should == "[[Jane]]\n[[John]]"
    end

    it "remove the last link" do
      pointer = Card.new :name=>"tp", :type=>"pointer", :content=>"[[Jane]]"
      pointer.drop_item "Jane"
      pointer.content.should == ""
    end
  end

  describe "watching" do
    it "not break on permissions" do
      watchers = Card.fetch "Home+*watchers", :new=>{}
      watchers.type_code.should == :pointer
      watchers << Account.current_id
      assert_equal '[[Joe User]]', watchers.content
    end
  end
end
