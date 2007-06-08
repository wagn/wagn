require File.dirname(__FILE__) + '/../../test_helper'
class Card::RoleTest < Test::Unit::TestCase
  common_fixtures
  
  def setup
    setup_default_user
  end
  
  def test_role_creation
    assert_instance_of Card::Role, Card::Role.create( :name=>'BananaMaster' )
    assert_instance_of ::Role, Card.find_by_name("BananaMaster").extension
  end
  
end
