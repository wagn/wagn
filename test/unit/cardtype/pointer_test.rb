require File.dirname(__FILE__) + '/../../test_helper'
class Card::PointerTest < ActiveSupport::TestCase       
  def setup 
    User.as :joe_user
  end
  
  context "add_reference" do
    setup do
      @pointer = Card.new :name=>"tp", :type=>"pointer", :content=>"[[Jane]]"
    end

    should "add link to content" do
      @pointer.add_reference "John"
      assert_equal "[[Jane]]\n[[John]]", @pointer.content
    end
    
    should "not add duplicate entries" do
      @pointer.add_reference "Jane"
      assert_equal "[[Jane]]", @pointer.content
    end
  end       
  
  context "remove_reference" do
    setup do
      @pointer = Card.new :name=>"tp", :type=>"pointer", :content=>"[[Jane]]\n[[John]]"
    end                                                                                
    
    should "remove the link" do
      @pointer.remove_reference "Jane" 
      assert_equal "[[John]]", @pointer.content
    end                                
    
    should "not fail on non-existent reference" do
      @pointer.remove_reference "Bigfoot" 
      assert_equal "[[Jane]]\n[[John]]", @pointer.content
    end
    
  end
     
  context "watching" do
    should "not break on permissions" do
      watchers = Card.find_or_new( :name => "Home+*watchers" )
      watchers.add_reference User.current_user.card.name
    end
  end
end
