# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'
require 'rr'


describe AccountController do

  it "should route to forgot_password" do
    { :get => "/account/forgot_password" }.should route_to( :controller => 'account', :action=>'forgot_password' )
  end

  describe "#signin" do
  end

  describe "#signout" do
  end

  describe "#forgot_password" do
    before do
      @msgs=[]
      mock.proxy(Mailer).confirmation_email.with_any_args.times(any_times) { |m|
        @msgs << m
        mock(@mail = m).deliver }

      @email='joe@user.com'
      @juser = Account[ @email ]
      post :forgot_password, :email=>@email
    end

    it 'should send an email to user' do
      @msgs.size.should == 1
      @msgs[0].should be_a Mail::Message
      # FIXME: shouldn't it be simpler? @msgs[0].from.should == "Anonymous"
      @msgs[0].from.should == ["no-reply@wagn.org"]
    end


    it "can't login now" do
  #    post :signin, :email=>'joe@user.com', :password=>'joe_pass'
    end
  end
end
