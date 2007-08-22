require File.dirname(__FILE__) + '/../../spec_helper'


describe Card, "should record appender" do
  before do
    User.as :admin
    @r = Role.find(:first)
    @c = Card.find(:first)
    @c.appender = @r
    @c.save!
  end

  it "should have appender immediately" do
    @c.appender.should == @r
  end
  
  it "should have appender after save" do
    Card.find(@c.id).appender.should == @r
  end         
end

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
