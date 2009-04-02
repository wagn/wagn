require File.dirname(__FILE__) + '/../../spec_helper'


describe User, "Anonymous User" do
  before do
    User.current_user = ::User['anon']
  end
  
  it "should ok anon role" do System.role_ok?(Role['anon'].id).should be_true end
  it "should not ok auth role" do System.role_ok?(Role['auth'].id).should_not be_true end
end

describe User, "Authenticated User" do
  before do
    User.current_user = ::User.find_by_login('joe_user')
  end
  it "should ok anon role" do System.role_ok?(Role['anon'].id).should be_true end
  it "should ok auth role" do System.role_ok?(Role['auth'].id).should be_true end
end


describe User, "Admin User" do
  before do
    User.current_user = ::User[:wagbot]

  end
  it "should ok admin role" do System.role_ok?(Role['admin'].id).should be_true end
end

describe User, 'Joe User' do
  before do
    User.as :joe_user
    User.cache.delete 'joe_user'
    @ju = User.current_user
    @r1 = Role.find_by_codename 'r1'
  end
  
  it "should initially have no roles" do
    @ju.roles.length.should==0
  end
  it "should immediately set new roles and return auth, anon, and the new one" do
    @ju.roles=[@r1]
    @ju.roles.length.should==1
  end
  it "should save new roles and reload correctly" do
    @ju.roles=[@r1]
    @ju = User.find_by_login 'joe_user'
    @ju.roles.length.should==1
  end
end