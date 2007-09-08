require File.dirname(__FILE__) + '/../../test_helper'
class Card::RemoveTest < Test::Unit::TestCase
  common_fixtures

  def setup
    setup_default_user
    @a = Card.find_by_name("A")
  end

     
  # I believe this is here to test a bug where cards with certain kinds of references
  # would fail to delete.  probably less of an issue now that delete is done through
  # trash.  
  def test_remove
    assert @a.destroy!, "card should be destroyable"
    assert_nil Card.find_by_name("A")
  end

end

