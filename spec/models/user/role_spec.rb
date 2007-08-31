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
    User.current_user = ::User.find_by_login('admin')
  end
  it "should ok admin role" do System.role_ok?(Role['admin'].id).should be_true end
end

