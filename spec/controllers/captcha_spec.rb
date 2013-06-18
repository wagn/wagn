# -*- encoding : utf-8 -*-
=begin
require 'wagn/spec_helper'
include AuthenticatedTestHelper

module CaptchaExampleGroupMethods
  def require_captcha_on(action, params)
    ENV['RECAPTCHA_PUBLIC_KEY'] = 'not nil'
    it action.to_s do
      require_captcha!
      post action, params
      #yield if block_given?
    end
  end
end

module CaptchaExampleMethods
  def require_captcha!
    @controller.should_receive(:verify_captcha).and_return(false)
  end
end

RSpec::Core::ExampleGroup.extend CaptchaExampleGroupMethods
RSpec::Core::ExampleGroup.send :include, CaptchaExampleMethods
#Spec::Rails::Example::ControllerExampleGroup.extend CaptchaExampleGroupMethods
#Spec::Rails::Example::ControllerExampleGroup.send(:include, CaptchaExampleMethods)

describe CardController, "captcha_required?" do
  before do
    Account.as_bot do
      Card["*all+*captcha"].update_attributes! :content=>"1"
      Card.create :name=>'Book+*type+*create', :type=>'Pointer', :content=>'[[Anonymous]]'
#      c=Card["Book"];c.permit(:create, Role[:anyone]);c.save!
      Card.create :name=>"Book+*type+*captcha", :content => "1"
    end
  end

  it "is false for joe user" do
    login_as :joe_user
    @controller.send(:captcha_required?).should be_false
  end

  context "for anonymous" do
    it "is true when global setting is true" do
      @controller.send(:captcha_required?).should be_true
    end

    it "is false when global setting is off" do
      Account.as_bot { c= Card['*all+*captcha']; c.content='0'; c.save! }
      @controller.send(:captcha_required?).should be_false
    end

    it "is true when type card setting is on and global setting is off" do
      Account.as_bot { c= Card['*all+*captcha']; c.content='0'; c.save! }
      get :new, :type=>"Book"
      @controller.send(:captcha_required?).should be_true
    end

    it "is false when type card setting is off and global setting is on" do
      Account.as_bot do
        c= Card['Book+*type+*captcha']; c.content='0'; c.save!
      end
      get :new, :type=>"Book"
      @controller.send(:captcha_required?).should be_false
    end
  end
end

describe CardController, "with captcha enabled requires captcha on" do
  before do
    Account.as_bot do
      Card["*all+*captcha"].update_attributes! :content=>"1"
      #FIXME it would be nice if there were a simpler idiom for this
      Card.create :name=>'Basic+*type+*create', :type=>'Pointer', :content=>'[[Anonymous]]'
      %w{ update delete }.each do |op|
        Card.create :name=>"A+*self+*#{op}", :type=>'Pointer', :content=>'[[Anyone]]'
      end
    end
  end

  require_captcha_on :create, :card=>{:name=>"TestA", :content=>"TestC"}
  require_captcha_on :remove, :id => "A"
  require_captcha_on :update, :id=>"A", :card=>{:name=>"Booker"}
  require_captcha_on :comment, :id=>"A", :card=>{:content=>"Yeah"}
end

describe AccountController, "with captcha enabled" do
  before do
    Account.as_bot do
      Card["*all+*captcha"].update_attributes! :content=>"1"
      #FIXME it would be nice if there were a simpler idiom for this
    end
  end

  Account.as Card::AnonID do
    require_captcha_on(
      :signup,
      :card => { :name => "Bob", :type=>"Account Request" },
      :account => { :email => "bob@user.com" }
    )
  end

end
=end
