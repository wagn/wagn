require File.dirname(__FILE__) + '/../../spec_helper'

# We're not supporting this any more, right?

=begin

describe User, "Normal user" do
  before do
    User.as :wagbot  do
      ::Role.cache={}
      r = Role.find_by_codename('auth')
      r.tasks = 'set_personal_card_permissions'
      r.save!        
    end
    @u = User.as :joe_user    
    @other_user = User[:wagbot]

    @xu = Card.create! :name=>'X+Joe User'
    @xo = Card.create! :name=>'X+Wagn Bot'
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



describe Card, "User not allowed to set personal cards" do
  before do
    ::Role.cache={}
    User.as :wagbot  do
      r = Role.find_by_codename('auth')
      r.tasks = ''
      r.save         
    end
    @u = User.as :joe_user
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
=end
