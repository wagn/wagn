require File.dirname(__FILE__) + '/../test_helper'
class RoleTest < ActiveSupport::TestCase
  
  include PermissionTestHelper
  
  def setup
    setup_default_user
    @anon = Role.find_by_codename("anon")
    @auth = Role.find_by_codename("auth")
    @admin_r = Role.find_by_codename("admin")
    @sample = Role.find_by_codename("Sample Role")

    @u1, @u2, @u3 = %w( u1 u2 u3 ).map do |x| ::User.find_by_login(x) end
    @r1, @r2, @r3, @r4 = %w( r1 r2 r3 r4).map do |x| ::Role.find_by_codename(x) end
    @c1, @c2, @c3 = %w( c1 c2 c3 ).map do |x| Card.find_by_name(x) end
  end

=begin 

  # I think subset is adequately covered below.  if not, we should find specific cases that break, cuz this
  # "test everything" one is too unwieldy to maintain.
  
  def test_all_roles_for_timing
     assert_equal( [
       ["admin","admin:true", "anon:false", "auth:false", "r1:false", "r2:false", "r3:false", "r4:false", "Sample Role:true"], 
       ["anon", "admin:true", "anon:true", "auth:true", "r1:true", "r2:true", "r3:true", "r4:true", "Sample Role:true"],
       ["auth", "admin:true", "anon:false", "auth:true", "r1:true", "r2:true", "r3:true", "r4:true", "Sample Role:true"], 
       ["r1", "admin:false", "anon:false", "auth:false", "r1:true", "r2:true", "r3:true", "r4:true", "Sample Role:true"],
       ["r2", "admin:false", "anon:false", "auth:false", "r1:false", "r2:true", "r3:true", "r4:false", "Sample Role:true"],
       ["r3", "admin:false", "anon:false", "auth:false", "r1:false", "r2:false", "r3:true", "r4:false", "Sample Role:true"], 
       ["r4", "admin:false", "anon:false", "auth:false", "r1:false", "r2:false", "r3:false", "r4:true", "Sample Role:true"],
       ["Sample Role","admin:false","anon:false","auth:false", "r1:false","r2:false", "r3:false", "r4:false", "Sample Role:true"]],
       Role.find(:all, :order=>'codename').map do |r1| [r1.codename]+Role.find(:all,:order=>'codename').map do |r2| "#{r2.codename}:#{r2.subset_of?(r1)}" end; end, "")
  end
=end

  
  def test_users_with_special_roles
    assert_same_by :id, User.active_users, @auth.users
  end
  
  def test_role_subset
    assert_equal false, @r1.subset_of?(@r2),"@r1.subset_of?(@r2)"
    assert_equal false, @r1.subset_of?(@r3),"@r1.subset_of?(@r3)"
    assert_equal false, @r1.subset_of?(@r4),"@r1.subset_of?(@r4)"

    assert_equal true,  @r2.subset_of?(@r1),"@r2.subset_of?(@r1)"
    assert_equal false, @r2.subset_of?(@r3),"@r2.subset_of?(@r3)"
    assert_equal false, @r2.subset_of?(@r4),"@r2.subset_of?(@r4)"

    assert_equal true,  @r3.subset_of?(@r1),"@r3.subset_of?(@r1)"
    assert_equal true,  @r3.subset_of?(@r2),"@r3.subset_of?(@r2)"
    assert_equal false, @r3.subset_of?(@r4),"@r3.subset_of?(@r4)"

    assert_equal true,  @r4.subset_of?(@r1),"@r4.subset_of?(@r1)"
    assert_equal false, @r4.subset_of?(@r2),"@r4.subset_of?(@r2)"
    assert_equal false, @r4.subset_of?(@r3),"@r4.subset_of?(@r3)"
  end
  
  def test_subset_roles
    assert_same_by :codename, [ @sample, @anon, @auth, @admin_r, @r1, @r2, @r3, @r4 ], @anon.subset_roles
    assert_same_by :codename, [ @sample, @r1,  @r2, @r3, @r4 ], @r1.subset_roles
    assert_same_by :codename, [ @sample, @r2, @r3 ], @r2.subset_roles
    assert_same_by :codename, [ @sample, @r3 ], @r3.subset_roles
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
