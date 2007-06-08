require File.dirname(__FILE__) + '/../test_helper'
class RecentChangesTest < Test::Unit::TestCase
  common_fixtures
  def setup
    setup_default_user
  end
  
  def test_cycle
    apple = newcard('apple', 'green')
    assert_equal 'created', last_change( apple )
    apple.revise( 'red' )
    assert_equal 'revised', last_change( apple )
    apple.rename( 'peach' )
    assert_equal 'renamed', last_change( apple )
    apple.destroy
    assert_equal 'removed', last_change( apple )
  end
  
  private
  
  def show_changes( card )
    RecentChange.find_all_by_card_id( card.id, :order=>"id DESC").each do |c|
      puts [card.name, c.action, c.changed_at].join("\t") 
    end
  end
  
  def last_change( card )
    change = RecentChange.find_by_card_id( card.id, :order=>'id DESC') || final_change( card )
    change.action
  end
  
  def final_change( card )
    grave = Grave.find_by_name( card.name )
    RecentChange.find_by_grave_id( grave.id, :order=>'id DESC' ) 
  end
  
end
