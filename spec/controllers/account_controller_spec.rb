# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'
include Wagn::AuthenticatedTestHelper
require 'rr'


describe CardController do
  describe "#signup" do
    before do
      @msgs=[]
      mock.proxy(Mailer).account_info.with_any_args.times(any_times) do |m|
        @msgs << m
        mock(m).deliver
      end
    end

    #FIXME: tests needed : signup without approval, signup alert emails



    it 'should send email' do
      post :create, :card=>{ :name=>'Joe New', :type_id=>Card::AccountRequestID, :account_args=>{:email=>'joe@new.com'} }
      login_as :joe_admin

      warn "updating now"
      post :update, :card=>{ :key=>'joe_new', :type_id=>Card::UserID}, :email=>{:subject=>'Hey Joe!', :message=>'Can I Come on in?'}

      @msgs.size.should == 1
      @msgs[0].should be_a Mail::Message
      #puts "msg looks like #{@msgs[0].inspect}"
    end


  end
  
  describe "#invite" do
    before do
      @msgs=[]
      mock.proxy(Mailer).account_info.with_any_args.times(any_times) { |m|
        @msgs << m
        mock(m).deliver }

      login_as 'joe_admin'
      @jadmin = Card['joe admin']
      @ja_email = @jadmin.account.email

      @email_args = {:subject=>'Hey Joe!', :message=>'Come on in.'}
      post :create, :card=>{ :name=>'Joe New', :type_id=>Card::UserID, :account_args=>{:email=>'joe@new.com'} },
        :email=> @email_args

      @cd_with_acct = Card['Joe New']
      @new_user = Account[ 'joe@new.com' ]

    end

    it 'should create a card, user, and account card' do
      assert_response :redirect
      @cd_with_acct.should be
      @new_user.should be
      @new_user.card_id.should == @cd_with_acct.id
      @cd_with_acct.type_id.should == Card::UserID
    end

    it 'should send email' do
      @msgs.size.should == 1
      @msgs[0].should be_a Mail::Message
      # FIXME: test may need updating, but we want cases that test the parsing
      #@msgs[0].from.should == "#{@jadmin.name} <#{@ja_email}>"
      @msgs[0].from.should == [ @ja_email ]
    end
  end

end


describe AccountController do

  describe "#signin" do
  end

  describe "#signout" do
  end

  describe "#forgot_password" do
    before do
      @msgs=[]
      mock.proxy(Mailer).account_info.with_any_args.times(any_times) { |m|
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
      post :signin, :email=>'joe@user.com', :password=>'joe_pass'
    end
  end
end
