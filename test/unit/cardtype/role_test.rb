require File.dirname(__FILE__) + '/../../test_helper'
class Card::RoleTest < Test::Unit::TestCase
  common_fixtures
  
  def setup
    setup_default_user
  end
  
  def test_role_creation
    assert_instance_of Card::Role, @c=Card::Role.create( :name=>'BananaMaster' )  
    assert_instance_of ::Role, @c.extension, "extension immediate"
    assert_instance_of ::Role, Card.find_by_name("BananaMaster").extension, "extension after save"
  end
  
end
