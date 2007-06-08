require File.dirname(__FILE__) + '/../test_helper'
class RoleTest < Test::Unit::TestCase
  common_fixtures
  test_helper :permission
  
  def setup
    setup_default_user
    @anon = Role.find_by_codename("anon")
    @auth = Role.find_by_codename("auth")
    @admin_r = Role.find_by_codename("admin")
    
    as(@admin) do
      @u1, @u2, @u3 = create_users %w( u1 u2 u3 ) 
      @r1, @r2, @r3, @r4 = create_roles %w( r1 r2 r3 r4 )
      @c1, @c2, @c3 = create_cards %w( c1 c2 c3 )
    end
    
    @r1.users = [ @u1, @u2, @u3 ]
    @r2.users = [ @u1, @u2 ]
    @r3.users = [ @u1 ]
    @r4.users = [ @u3, @u2 ]
  end

  def test_users_with_special_roles
    assert_same_by :id, User.active_users, @auth.users
  end
  
  def test_role_subset
    assert_equal false, @r1.subset_of?(@r2)
    assert_equal false, @r1.subset_of?(@r3)
    assert_equal false, @r1.subset_of?(@r4)
    
    assert_equal true,  @r2.subset_of?(@r1)
    assert_equal false, @r2.subset_of?(@r3)
    assert_equal false, @r2.subset_of?(@r4)
    
    assert_equal true,  @r3.subset_of?(@r1)
    assert_equal true,  @r3.subset_of?(@r2)
    assert_equal false, @r3.subset_of?(@r4)

    assert_equal true,  @r4.subset_of?(@r1)
    assert_equal false, @r4.subset_of?(@r2)
    assert_equal false, @r4.subset_of?(@r3)
  end
  
  def test_subset_roles
    assert_same_by :codename, [ @anon, @auth, @admin_r, @r1, @r2, @r3, @r4 ], @anon.subset_roles
    assert_same_by :codename, [ @r1,  @r2, @r3, @r4 ], @r1.subset_roles
    assert_same_by :codename, [ @r2, @r3 ], @r2.subset_roles
    assert_same_by :codename, [ @r3 ], @r3.subset_roles
  end
  
  def test_superset_roles
    assert_same_by :codename, [ @auth, @anon, @admin_r ], @admin_r.superset_roles
    assert_same_by :codename, [ @auth, @anon, @r2, @r1, @r3 ], @r3.superset_roles
    assert_same_by :codename, [ @auth, @anon, @r1, @r4 ], @r4.superset_roles
    assert_same_by :codename, [ @auth, @anon, @r1 ], @r1.superset_roles
  end
  
  private
  def assert_same_by( method, list1, list2, msg='' )
    assert_equal list1.plot(method).sort, list2.plot(method).sort, msg
  end
  
end
