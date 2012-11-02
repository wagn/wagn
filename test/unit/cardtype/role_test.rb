require File.expand_path('../../test_helper', File.dirname(__FILE__))
class Wagn::Set::Type::RoleTest < ActiveSupport::TestCase


  def setup
    super
    setup_default_user
  end

  def test_role_creation
    @c=Card.create( :type=>'Role', :name=>'BananaMaster' )
    assert @c.type_id==Card::RoleID
  end

end
