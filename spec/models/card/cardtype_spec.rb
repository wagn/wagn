require File.dirname(__FILE__) + '/../../spec_helper'
=begin
describe Card, "type" do
  @@ct = {}
  before do
    User.as :admin
    Cardtype.find(:all).plot(:class_name).map do |ct|
      @@ct[ct] = Card.const_get(ct).create :name=>"new #{ct}"
    end
  end
  
  Cardtype.find(:all).plot(:class_name).each do |ct|
    it "#{ct} should have editor_type" do
      @@ct[ct].editor_type.should_not be_nil
    end
  end
end
=end

describe User, "Joe User" do
  before do
    User.as :admin
    @r3 = Role[:r3]
    @ctf_t = Card.create! :name=>'Cardtype F+*template'
    @ctf_t.permit(:create, @r3)
    @ctf_t.save!

    User.as :joe_user
    @user = User[:joe_user]
    @ctf = Card['Cardtype F']
    @cardtype_names = @user.createable_cardtypes.map{ |ct| ct[:name] }
  end

  it "should not have r3 permissions" do
    @user.roles.member?(@r3).should_not be_true
  end
  it "should ponder creating a card of Cardtype F, but find that he lacks create permissions" do
    @ctf.ok?(:create).should_not be_true
  end
  it "should not find Cardtype F on its list of createable cardtypes" do
    @cardtype_names.member?('Cardtype F').should_not be_true
  end
  it "should find Basic on its list of createable cardtypes" do
    @cardtype_names.member?('Basic').should be_true
  end
end