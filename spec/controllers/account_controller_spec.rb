require File.expand_path('../spec_helper', File.dirname(__FILE__))
include AuthenticatedTestHelper
require 'rr'

describe AccountController, "account functions" do
  before do
    #@user_card = Account.authorized
    @user_card = Account.user_card
    #warn "auth is #{@user_card.inspect}"
  end

  it "should signin" do
    #post :create, :id=>'Session', :account => {:email => 'joe@user.org', :password => 'joe_pass' }
    post :signin, :account => {:email => 'joe@user.org', :password => 'joe_pass' }
  end

  it "should signout" do
    login_as 'joe_user'
    Account.user.id.should == Card['joe user'].id
    
    signout
    Account.user.id.should == Card::AnonID
    Card[:session].should be
  end

  describe "invite: POST *account" do
    before do
      @msgs=[]
      mock.proxy(Mailer).account_info.with_any_args.times(any_times) { |m|
        @msgs << m
        mock(m).deliver }

      @email_args = {:subject=>'Hey Joe!', :message=>'Come on in.'}
      #post :create, :id=>'*account', :account=>{:email=>'joe@new.com'}, :card=>{:name=>'Joe New'}, :email=> @email_args
      post :signup, :account=>{:email=>'joe@new.com'}, :card=>{:name=>'Joe New'}, :email=> @email_args

      @user_card = Card['Joe New']
      @new_user = User.where(:email=>'joe@new.com').first

    end

    it "should invite" do
      @user_card.should be
      @user_card.id.should be
    end

  end

  describe "signup, send mail and accept" do
    before do
      @msgs=[]
      mock.proxy(Mailer).account_info.with_any_args.times(any_times) do |m|
        @msgs << m
        mock(m).deliver
      end

      Account.user_id.should == Card::AnonID
      #post :create, :id=>'*account', :card => {:name => "Joe New"}, :account=>{:email=>"joe_new@user.org", :password=>'new_pass', :password_confirmation=>'new_pass'}
      post :signup, :card => {:name => "Joe New"}, :account=>{:email=>"joe_new@user.org", :password=>'new_pass', :password_confirmation=>'new_pass'}
    end

    it 'should send email' do
      @msgs.size.should == 1
      @msgs[0].should be_a Mail::Message
      # should be from
    end

    it "should create an account request" do
      c = Card['Joe New'].should be
      c.type_id.should == Card::AccountRequestID
      c.to_user.blocked?.should be_true
    end

    it 'should detect duplicates' do
      post :signup, :user=>{:email=>'joe@user.com'}, :card=>{:name=>'Joe Scope'}
      post :signup, :user=>{:email=>'joe@user.com'}, :card=>{:name=>'Joe Duplicate'}
      
      #s=Card['joe scope']
      c=Card['Joe Duplicate']
      c.should be_nil
    end

    it "should accept" do
      #put :update, :id=>"Joe New", :account=>{:status=>'active'}
      put :accept, :card=>{:key => "joe_new"}, :account=>{:status=>'active'}

      @user_card = Card['Joe New'].should be
      @new_user = @user_user.to_user.should be
      @new_user.card_id.should == @user_card.id
      @user_card.type_id.should == Card::UserID
      @msgs.size.should == 2
    end
  end

private

  def signout
    #delete :delete, :id=>'Session'
    delete :signout
  end

end

describe AccountController, "account tests" do
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.

  include AuthenticatedTestHelper

  describe "#forgot_password" do
    before do
      @msgs=[]
      mock.proxy(Mailer).account_info.with_any_args.times(any_times) do |m|
        @msgs << m
        mock(@mail = m).deliver 
      end

      @email='joe@user.com'
      @juser=User.where(:email=>@email).first
      #put :update, :id=>'*account', :email=>@email
      post :forgot_password, :email=>@email, :controller=>:account
    end

    it 'should send an email to user' do
      @msgs.size.should == 1
      @msgs[0].should be_a Mail::Message
    end


    it "can't login now" do
      #post :create, :id=>'Session', :email=>'joe@user.com', :password=>'joe_pass'
      post :signin, :email=>'joe@user.com', :password=>'joe_pass'
    end
  end

  # Note-- account creation is handled in it's own file account_creation_test


  before do
    @newby_email = 'newby@wagn.net'
    @newby_args =  {:user=>{ :email=>@newby_email },
                    :card=>{ :name=>'Newby Dooby' }}
    Account.as_bot do
      Card.create(:name=>'Account Request+*type+*captcha', :content=>'0')
    end

    signout
  end

  it "should test_should_login_and_redirect" do
    #post :action, :id=>'Session', :login => 'u3@user.com', :password => 'u3_pass'
    post :signin, :login => 'u3@user.com', :password => 'u3_pass'
    assert session[:user]
    assert_response :redirect
  end

  it "should test_should_fail_login_and_not_redirect" do
    #post :action, :id=>'Session', :login => 'webmaster@grasscommons.org', :password => 'bad password'
    post :signin, :login => 'webmaster@grasscommons.org', :password => 'bad password'
    assert_nil session[:user]
    assert_response 403
  end

  it "should test_should_signout" do
    get :signout
    assert_nil session[:user]
    assert_response :redirect
  end

  it "should test_create_successful" do
    login_as 'joe_user'
    assert_difference ActionMailer::Base.deliveries, :size do
      assert_new_account do
        post_invite
      end
    end
  end

  it "should test_signup_form" do
    #get :action, :id=>'*account+*signup'
    #get :read, :id=>'*signup'
    get :signup
    assert_response 200
  end

  it "should test_signup_with_approval" do
    #post :action, @newby_args.merge(:id=>'*account')
    post :signup, @newby_args.merge(:id=>'*account')

    assert_response :redirect
    assert Card['Newby Dooby'], "should create User card"
    assert_status @newby_email, 'pending'

    #put :action, :id=>'newby_dooby', :card=>{:key=>'newby_dooby'}, :email=>{:subject=>'hello', :message=>'world'}
    #put :update, :id=>'newby_dooby', :card=>{:key=>'newby_dooby'}, :email=>{:subject=>'hello', :message=>'world'}
    put :signup, :card=>{:key=>'newby_dooby'}, :email=>{:subject=>'hello', :message=>'world'}
    assert_response :redirect
    assert_status @newby_email, 'active'
  end

  it "should test_signup_without_approval" do
    Account.as_bot do  #make it so anyone can create accounts (ie, no approval needed)
      create_accounts_rule = Card['*account+*right'].fetch(:trait=>:create)
      create_accounts_rule << Card::AnyoneID
      create_accounts_rule.save!
    end
    #post :action,  @newby_args.merge(:status=>'active',:id=>'*account+*signup')
    post :signup,  @newby_args.merge(:status=>'active',:id=>'*signup')
    assert_response :redirect
    assert_status @newby_email, 'active'
  end

  it "should test_dont_let_blocked_user_signin" do
    u = User.find_by_email('u3@user.com')
    u.blocked = true
    u.save
    #post :action, :id=>'Session', :login => 'u3@user.com', :password => 'u3_pass'
    post :signin, :login => 'u3@user.com', :password => 'u3_pass'
    assert_response 403
    assert_template ('signin')
  end

  it "should test_forgot_password" do
    #post :action, :id=>'Session+*reset_password', :email=>'u3@user.com'
    post :forgot_password, :email=>'u3@user.com'
    assert_response :redirect
  end

  it "should test_forgot_password_not_found" do
    #post :action, :id=>'Session+*reset_password', :email=>'nosuchuser@user.com'
    post :forgot_password, :email=>'nosuchuser@user.com'
    assert_response 404
  end

  it "should test_forgot_password_blocked" do
    email = 'u3@user.com'
    Account.as_bot do
      u = User.find_by_email(email)
      u.status = 'blocked'
      u.save!
    end
    #post :action, :id=>'Session+*reset_password', :email=>email
    post :forgot_password, :email=>email
    assert_response 403
  end

end
=begin
require File.expand_path('../test_helper', File.dirname(__FILE__))
require 'card_controller'

# Re-raise errors caught by the controller.
class CardController; def rescue_action(e) raise e end; end

class AccountCreationTest < ActionController::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.

  include AuthenticatedTestHelper



  #FIXME - couldn't get this stuff to work in setup, but that's where it belongs.
  signed_in = Card[Card::AuthID]
  # need to use: Card['*account'].ok?(:create)
  #if (tasks_card=Card.fetch(!signed_in.fetch(:trait=>:task_list), :new=>{})).
  #     item_names.member?('create_accounts')
  #  tasks_card << 'create_accounts'
  #end

  def setup
    super
    get_renderer
    @controller = CardController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    #login_as 'joe_admin'
    login_as 'joe_admin'
    Wagn::Cache.restore
  end

# this is working in interface but I can't get it to work here:
=begin
  it "should test_should_require_valid_cardname" do
#    assert_raises(ActiveRecord::RecordInvalid) do
    assert_no_new_account do
      post_invite :card => { :name => "Joe+User/" }
    end
  end

  it "should test_should_create_account_from_account_request" do
    assert_equal :account_request, (c=Card.fetch('Ron Request')).typecode
    post_invite :card=>{ :key=>"ron_request"}, :action=>:accept
    c=Card.fetch('Ron Request')
    assert_equal :user, c.typecode
    assert_equal "active", User.find_by_email("ron@request.com").status
  end

  it "should test_should_create_account_from_account_request_when_user_hard_templated" do
    Account.as_bot { Card.create :name=>'User+*type+*content', :content=>"like this" }
    assert_equal :account_request, (c=Card.fetch('Ron Request')).typecode
    post_invite :card=>{ :key=>"ron_request"}, :action=>:accept
    c=Card.fetch('Ron Request')
    assert_equal :user, c.typecode
    assert_equal "active", User.find_by_email("ron@request.com").status
  end


  it "should test_create_permission_denied_if_not_logged_in" do
    signout
    #delete :action, :id=>'Session'
    delete :delete, :id=>'Session'
    assert_no_new_account do
#    assert_raises(Card::PermissionDenied) do
      post_invite
    end
  end



  it "should test_should_create_account_from_scratch" do
    assert_difference ActionMailer::Base.deliveries, :size do
      assert_new_account do
        post_invite
        assert_response 302
      end
    end
    email = ActionMailer::Base.deliveries[-1]
    # emails should be 'from' inviting user
    assert_equal Account.user.email, email.from[0]
    assert_equal 'active', User.find_by_email('new@user.com').status
    assert_equal 'active', User.find_by_email('new@user.com').status
  end

  it "should test_should_create_account_when_user_cards_are_templated   ##FIXME -- I don't think this actually catches the bug I saw." do
    Account.as_bot { Card.create! :name=> 'User+*type+*content'}
    assert_new_account do
      post_invite
      assert_response 302
    end
  end

  # should work -- we generate a password if it's nil
  it "should test_should_generate_password_if_not_given" do
    assert_new_account do
      post_invite
      assert !assigns(:user).password.blank?
    end
  end

  it "should test_should_require_password_confirmation_if_password_given" do
    assert_no_new_account do
      #assert_raises(ActiveRecord::RecordInvalid) do
        post_invite :user=>{ :password=>'tedpass' }
      #end
    end
  end

  it "should test_should_require_email" do
    assert_no_new_account do
      #assert_raises(ActiveRecord::RecordInvalid) do
        post_invite :user=>{ :email => nil }
        assert assigns(:user).errors[:email]
        assert_response :success
      #end
    end
  end

  it "should test_should_require_unique_email" do
    post_invite :user=>{ :email=>'duplor@user.com' }
    assert_no_new_account do
      post_invite :user=>{ :email=>'duplor@user.com' }
    end
  end

  it "should test_should_create_account_from_existing_user" do
    assert_difference ::User, :count do
      assert_no_difference Card.where(:type_id=>Card::UserID), :count do
        post_invite :card=>{ :name=>"No Count" }, :user=>{ :email=>"no@count.com" }
      end
    end
  end
end
require File.expand_path('../test_helper', File.dirname(__FILE__))
require 'card_controller'

# Re-raise errors caught by the controller.
class CardController; def rescue_action(e) raise e end; end
class AccountRequestTest < ActionController::TestCase

  include AuthenticatedTestHelper

  def setup
    super
    get_renderer
    @controller = CardController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    Account.as_bot do
      Card.create(:name=>'Account Request+*type+*captcha', :content=>'0')
    end
  end

  it "should test_should_redirect_to_account_request_landing_card" do
    #post :action, :user=>{:email=>"jamaster@jay.net"}, :card=>{
    post :create, :user=>{:email=>"jamaster@jay.net"}, :card=>{
      :type=>"Account Request",
      :name=>"Word Third",
      :content=>"Let me in!"
    }

    @card =  Card["Word Third"]
    @user = User.where(:card_id=>@card.id).first

    assert_equal @card.typecode, :account_request

    assert_response 302

    # this now happens only when created via account controller

    #assert_instance_of ::User, @user
    #assert_equal 'jamaster@jay.net', @user.email
    #assert_equal 'request', @user.status

  end

  it "should test_should_destroy_and_block_user" do
    login_as 'joe_admin'
    # FIXME: should test agains mocks here, instead of re-testing the model...
    #delete :action, :id=>"~#{Card.fetch('Ron Request').id}"
    delete :delete, :id=>"~#{Card.fetch('Ron Request').id}"
    assert_equal nil, Card.fetch('Ron Request')
    assert_equal 'blocked', User.find_by_email('ron@request.com').status
  end

end



class AccountTest < ActionController::IntegrationTest
  include LocationHelper

  it "should test_return_to_home_page_after_login" do
    #post '/Session', :login=>'joe@user.com', :password=>'joe_pass'
    post '/account/signin', :login=>'joe@user.com', :password=>'joe_pass'
    assert_redirected_to '/'
  end

  it "should test_return_to_special_url_when_logging_in_after_visit" do
    get '/recent'
    #post '/Session', :login=>'joe@user.com', :password=>'joe_pass'
    post '/account/signin', :login=>'joe@user.com', :password=>'joe_pass'
    assert_redirected_to '/*recent'
  end

end
=end
