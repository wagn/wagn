require File.dirname(__FILE__) + '/../../test_helper'
class Card::PointerTest < Test::Unit::TestCase       
  setup do
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

end
