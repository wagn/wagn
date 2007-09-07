require File.dirname(__FILE__) + '/../../spec_helper'



describe User, "Normal user" do
  before do
    User.as :admin
    r = Role.find_by_codename('auth')
    r.tasks = 'set_personal_card_permissions'
    r.save
    User.as :joe_user
    @u = User.current_user    
    @other_user = User.find_by_login('admin')
    @xu = Card.create! :name=>'X+Joe User'
    @xo = Card.create! :name=>'X+Admin User'
    @ux = Card.create! :name=>'Joe User+X'
    @xuy= Card.create! :name=>'X+Joe User+Y'
  end

  
  it "should be someone with permission to set personal card permissions" do
    System.ok?(:set_personal_card_permissions).should be_true
  end
  it "should not be able to any card permissions" do
    System.ok?(:set_card_permissions).should be_false
  end
  it "should not be the personal user of its own user card (no personal user)" do
    @u.card.personal_user.should== nil
  end
  it "should not be able to edit its card permissions" do
    @u.card.ok?(:permissions).should be_false
  end
  it "should be the personal user of (card)+(user card)" do
    @xu.personal_user.should== @u
  end
  it "should be able to edit personal cards where it is the personal user" do
    @xu.ok?(:permissions).should be_true
  end
  it "should not be able to edit personal cards where other users are the personal user" do
    @xo.ok?(:permissions).should_not be_true
  end
  it "should not be the personal user of (own user card)+(card)" do
    @ux.personal_user.should== nil
  end
  it "should be the personal user of (own personal card)+(card)" do
    @xuy.personal_user.should== @u
  end
end


## This is f'ed up.  Run either of these test sets on its own and it passes; together (in either order) and the second fails.
## something's not getting reset.

describe Card, "User not allowed to set personal cards" do
  before do
    User.as :admin
    r = Role.find_by_codename('auth')
    r.tasks = ''
    r.save
    User.as :joe_user

    @u = User.current_user 
    @xu = Card.create! :name=>'X+Joe User'

  end

  it "should be someone without permission to set personal card permissions" do
    System.ok?(:set_personal_card_permissions).should be_false
  end
  it "should not be able to any card permissions" do
    System.ok?(:set_card_permissions).should be_false
  end
  it "should not allow (card)+(self card) to be personal" do
    @xu.ok?(:permissions).should_not be_true
  end  
end

