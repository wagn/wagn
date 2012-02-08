require File.expand_path('../spec_helper', File.dirname(__FILE__))
include AuthenticatedTestHelper
require 'rr'

describe AccountController do

  describe "#signup" do
  end
  describe "#accept" do
    before do
      login_as :joe_user
      @user = Card.user
    end

  end
  describe "#invite" do
    before do
      mock.instance_of(Mailer) do |m|
        @mailer = m
        mock(m).account_info.with_any_args
      end

      login_as :joe_user

      @email_args = {:subject=>'Hey Joe!', :message=>'Come on in.'}
      post :invite, :user=>{:email=>'joe@new.com'}, :card=>{:name=>'Joe New'},
        :email=> @email_args

      @new_user = User.where(:email=>'joe@new.com').first
    end

    it 'should create a user' do
      @new_user.should be
    end

    it 'should send email' do
      @mailer.should have_received.account_info(@new_user, @email_args[:subject], @email_args[:message])
    end
  end

  describe "#signin" do
  end

  describe "#signout" do
  end

  describe "#forgot_password" do
    before do
      any_instance_of(Mailer) do
        mock(Mailer).account_info.with_any_args
      end

      @email='joe@user.com'
      @juser=User.where(:email=>@email).first
      post :forgot_password, :email=>@email
    end

    it 'should send an email to user' do
      Mailer.should have_received.account_info(@juser, "Password Reset",
          "You have been given a new temporary password.  " +
          "Please update your password once you've signed in. ")
    end


    it "can't login now" do
      post :signin, :email=>'joe@user.com', :password=>'joe_pass'
    end
  end
end
