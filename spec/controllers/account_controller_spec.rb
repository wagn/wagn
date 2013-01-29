require File.expand_path('../spec_helper', File.dirname(__FILE__))
include AuthenticatedTestHelper
require 'rr'

describe AccountController do

  describe "#accept" do
    before do
      login_as :joe_user
      @user = Account.user
    end
  end
  
  describe "#invite" do
    before do
      @msgs=[]
      mock.proxy(Mailer).account_info.with_any_args.times(any_times) { |m|
        @msgs << m
        mock(m).deliver }

      login_as :joe_admin

      @email_args = {:subject=>'Hey Joe!', :message=>'Come on in.'}
      post :invite, :user=>{:email=>'joe@new.com'}, :card=>{:name=>'Joe New'},
        :email=> @email_args

      @auth_card = Card['Joe New']
      @new_user = User.where(:email=>'joe@new.com').first

    end

    it 'should create a user' do
      @new_user.should be
      @new_user.card_id.should == @auth_card.id
      @auth_card.type_id.should == Card::UserID
    end

    it 'should send email' do
      @msgs.size.should == 1
      @msgs[0].should be_a Mail::Message
    end
  end

  describe "#signup" do
    before do
      @msgs=[]
      mock.proxy(Mailer).account_info.with_any_args.times(any_times) do |m|
        @msgs << m
        mock(m).deliver
      end
    end

    #FIXME: tests needed : signup without approval, signup alert emails

    it 'should create a user' do
      #warn "who #{Account.authorized.inspect}"
      post :signup, :user=>{:email=>'joe@new.com'}, :card=>{:name=>'Joe New'}
      new_user = User.where(:email=>'joe@new.com').first
      @auth_card = Card['Joe New']
      new_user.should be
      new_user.card_id.should == @auth_card.id
      new_user.pending?.should be_true
      @auth_card.type_id.should == Card::AccountRequestID
    end

    it 'should send email' do
      post :signup, :user=>{:email=>'joe@new.com'}, :card=>{:name=>'Joe New'}
      login_as :joe_admin

      post :accept, :card=>{:key=>'joe_new'}, :email=>{:subject=>'Hey Joe!', :message=>'Can I Come on in?'}

      @msgs.size.should == 1
      @msgs[0].should be_a Mail::Message
      #puts "msg looks like #{@msgs[0].inspect}"
    end

    it 'should detect duplicates' do
      post :signup, :user=>{:email=>'joe@user.com'}, :card=>{:name=>'Joe Scope'}
      post :signup, :user=>{:email=>'joe@user.com'}, :card=>{:name=>'Joe Duplicate'}
      
      #s=Card['joe scope']
      c=Card['Joe Duplicate']
      c.should be_nil
    end
  end

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
      @juser=User.where(:email=>@email).first
      post :forgot_password, :email=>@email
    end

    it 'should send an email to user' do
      @msgs.size.should == 1
      @msgs[0].should be_a Mail::Message
    end


    it "can't login now" do
      post :signin, :email=>'joe@user.com', :password=>'joe_pass'
    end
  end
end
