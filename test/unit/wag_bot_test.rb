require File.dirname(__FILE__) + '/../test_helper'
class WagBotTest < Test::Unit::TestCase
  common_fixtures
  def setup
    setup_default_user
  end
  
  def test_instance
    assert_instance_of User, WagBot.instance
  end
  
  def test_revise_card()
    brownie = newcard('brownie', 'mmmm')
    WagBot.instance.revise_card( brownie, 'damn good' )
    brownie.reload
    assert_equal 'damn good', brownie.content
    assert_equal WagBot.instance, brownie.current_revision.created_by, "revision created by wagbot"
  end
  
  def test_revise_simple_card_links()
    apple = newcard('apple', 'foobar [[banana]]')
    assert_equal ['banana'], apple.out_references.plot(:referenced_name)
    WagBot.instance.revise_card_links( apple, 'banana', 'orange')
    assert_equal 'foobar [[orange]]', apple.reload.content
    assert_equal ['orange'], apple.out_references(refresh=true).plot(:referenced_name)    
  end
  
  def test_revise_connection_card_links()
    apple = newcard('apple', 'foobar [[banana]]')
    assert_equal ['banana'], apple.out_references.plot(:referenced_name)
    WagBot.instance.revise_card_links( apple, 'banana', 'orange')
    assert_equal 'foobar [[orange]]', apple.reload.content
    assert_equal ['orange'], apple.out_references(refresh=true).plot(:referenced_name)    
  end
  
  def test_revise_separate_links()
    apple = newcard('apple', 'foobar [[banana|boots]]')
    assert_equal ['banana'], apple.out_references.plot(:referenced_name)
    WagBot.instance.revise_card_links( apple, 'banana', 'orange')
    assert_equal 'foobar [[orange|boots]]', apple.reload.content
    assert_equal ['orange'], apple.out_references(refresh=true).plot(:referenced_name)    
  end
  
  
end
