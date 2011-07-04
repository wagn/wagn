require File.dirname(__FILE__) + '/../test_helper'
class RoleTest < ActiveSupport::TestCase
  
  include PermissionTestHelper
  
  def setup
    super
    setup_default_user
    @auth = Role.find_by_codename("auth")
  end

  def test_users_with_special_roles
    assert_same_by :id, User.active_users, @auth.users
  end
  
  private
  def assert_same_by( method, list1, list2 )
    assert_equal list1.plot(method).sort, list2.plot(method).sort
  end
  
end
