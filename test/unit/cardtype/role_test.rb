require File.dirname(__FILE__) + '/../../test_helper'
class Card::RoleTest < ActiveSupport::TestCase
  
  
  def setup
    super
    setup_default_user
  end
  
  def test_role_creation
    @c=Card.create( :typecode=>'Role', :name=>'BananaMaster' )  
    assert @c.class.include?(Card::Role)  
    assert_instance_of ::Role, @c.extension, "extension immediate"
    assert_instance_of ::Role, Card.find_by_name("BananaMaster").extension, "extension after save"
  end
  
end
