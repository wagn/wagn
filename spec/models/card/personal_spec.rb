require File.dirname(__FILE__) + '/../../spec_helper'



describe Card, "should recognize personal card candidates" do
  before do
    User.as :joe_user
    @u = User.current_user    
    @other_user = User.find_by_login('admin')
    @xu = Card.create! :name=>'X+Joe User'
    @xo = Card.create! :name=>'X+Admin User'
    @ux = Card.create! :name=>'Joe User+X'
    @xuy= Card.create! :name=>'X+Joe User+Y'
    
  end
  
  it "should not allow user cards to be personal cards" do
    @u.card.ok?(:personal_card).should_not be_true
  end
  it "should allow (card)+(own user cards) to be personal" do
    @xu.ok?(:personal_card).should be_true
  end
  it "should not allow (card)+(other user's card) to be personal" do
    @xo.ok?(:personal_card).should_not be_true
  end
  it "should not allow (own user card)+(card) to be personal" do
    @ux.ok?(:personal_card).should_not be_true
  end
  it "should allow (personal card)+(card) to be personal" do
    @xuy.ok?(:personal_card).should be_true
  end
  
end

describe Card, "Anonymous User can't have personal cards" do
  before do
    User.as :anon
    @u = User.current_user 
    @xu = Card.create :name=>'X+Anonymous User'
  end
  
  it "should not allow (card)+(anonymous user's card) to be personal" do
    @xu.ok?(:personal_card).should_not be_true
  end  
end
