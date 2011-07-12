require File.dirname(__FILE__) + '/../../test_helper'
class Wagn::Set::Type::RoleTest < ActiveSupport::TestCase
  
  
  def setup
    super
    setup_default_user
  end
  
  def test_role_creation
    @c=Card.create( :type=>'Role', :name=>'BananaMaster' ) 
    assert @c.typecode=='Role'
    assert_instance_of ::Role, @c.extension, "extension immediate"
    assert_instance_of ::Role, Card.find_by_name("BananaMaster").extension, "extension after save"
  end
  
end
