require File.dirname(__FILE__) + '/../../test_helper'
class Card::PriorityTest < Test::Unit::TestCase
  common_fixtures
  def setup
    setup_default_user
  end
  
  def test_priority
    priority = newcard('*priority')
    
    banana = newcard('Banana')
    apple  = newcard('Apple')
    
    color   = newcard('Color')
    
    banana_color = banana.connect color, "Yellow"
    apple_color = apple.connect color, "Red"
    
    color_priority = color.connect priority, "100"
    assert_equal 100, color.reload.priority
    assert_equal 100, banana_color.reload.priority
    assert_equal 100, apple_color.reload.priority
    
    color_priority.revise("-20")
    assert_equal -20, banana_color.reload.priority
    assert_equal -20, apple_color.reload.priority
    
    apple_color_priority = apple_color.connect priority, "50"
    assert_equal 50, apple_color.reload.priority
    
    color_priority.revise("10")
    assert_equal 10, banana_color.reload.priority
    assert_equal 50, apple_color.reload.priority
  end
  
end


