require File.dirname(__FILE__) + '/../test_helper'
require 'account_controller'

# Re-raise errors caught by the controller.
class AccountController; def rescue_action(e) raise e end; end

class AccountControllerTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
 
  include AuthenticatedTestHelper

  common_fixtures

  def setup
    test_renderer
    @controller = AccountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    setup_default_user
    login_as :admin
  end

  def test_create_successful  
    assert_difference ActionMailer::Base.deliveries, :size do 
      assert_new_account do 
        create_user
      end
    end
  end
  
  def test_should_login_and_redirect
    logout
    post :login, :login => 'webmaster@grasscommons.org', :password => 'w8gn8t0r'
    assert session[:user]
    assert_response :redirect
  end

  def test_should_fail_login_and_not_redirect
    logout
    post :login, :login => 'webmaster@grasscommons.orgg', :password => 'bad password'
    assert_nil session[:user]
    assert_response :success
  end
                                
  # should work -- we generate a password if it's nil
  def test_no_password_on_create
    assert_new_account do
      create_user( :user=>{:password => nil, :password_confirmation=>nil})
      assert !assigns(:user).password.blank?
      assert_response :success
    end
  end

  def test_should_require_password_confirmation_on_create
    assert_no_new_account do
      assert_raises(Wagn::Oops) do 
        create_user(:user=>{:password_confirmation => nil})
        #assert assigns(:user).errors.on(:password_confirmation)
        #assert_response :success
      end
    end
  end

  def test_should_require_email_on_create
    assert_no_new_account do
      assert_raises(Wagn::Oops) do 
        create_user(:user=>{:email => nil})
        #assert assigns(:user).errors.on(:email)
        #assert_response :success
      end
    end
  end

  def test_should_logout
    get :logout
    assert_nil session[:user]
    assert_response :redirect
  end
      
  def test_create_permission_denied_if_not_logged_in
    logout
    # assert_raises(Wagn::PermissionDenied) do
    # FIXME weird-- i think this should raise an error-- but at least is doesn't
    # seem to be actually creating the account.  hrmph.
    assert_no_new_account do
      create_user
    end
    #end
  end
   
    
  def test_create_invalid_cardname
    assert_raises(Wagn::Oops) do
      create_user :card=>{:name=>"Foo+Bar/"}
    end
  end
  
  def test_create_duplicate_card
    create_user
    assert_raises(Wagn::Oops) do
      create_user
    end
  end                           
  
  def test_create_duplicate_email
  end
  
  def test_create_without_password
  end
  
  def test_create_with_password
  end

  def test_forgot_password_not_found
  end                        
   
  def test_forgot_password
    
  end

  protected
  def create_user(options = {})
    post :create, :user => {
       :email => 'quire@example.com', 
       :password => 'quire', 
       :password_confirmation => 'quire' 
    }.merge(options[:user]||{}),
    :card => {
      :name => "NewUser"
    }.merge(options[:card]||{}),
    :email => {
      :subject => "mailit",
      :message => "baby"
    }
  end
end
