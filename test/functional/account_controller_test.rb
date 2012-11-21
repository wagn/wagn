require File.expand_path('../test_helper', File.dirname(__FILE__))
require 'account_controller'

# Re-raise errors caught by the controller.
class AccountController; def rescue_action(e) raise e end; end

class AccountControllerTest < ActionController::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
  include AuthenticatedTestHelper

  # Note-- account creation is handled in it's own file account_creation_test



  def setup
    super
    get_renderer
    @controller = AccountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @newby_email = 'newby@wagn.net'
    @newby_args =  {:user=>{ :email=>@newby_email },
                    :card=>{ :name=>'Newby Dooby' }}
    Session.as_bot do
      Card.create(:name=>'Account Request+*type+*captcha', :content=>'0')
    end
    signout
  end


  def test_should_login_and_redirect
    post :signin, :login => 'u3@user.com', :password => 'u3_pass'
    assert session[:user]
    assert_response :redirect
  end

  def test_should_fail_login_and_not_redirect
    post :signin, :login => 'webmaster@grasscommons.org', :password => 'bad password'
    assert_nil session[:user]
    assert_response 403
  end

  def test_should_signout
    get :signout
    assert_nil session[:user]
    assert_response :redirect
  end

  def test_create_successful
    integration_login_as 'joe_user', true
    #login_as 'joe_user'
    assert_difference ActionMailer::Base.deliveries, :size do
      assert_new_account do
        post_invite
      end
    end
  end

  def test_signup_form
    get :signup
    assert_response 200
  end

  def test_signup_with_approval
    post :signup, @newby_args

    assert_response :redirect
    assert Card['Newby Dooby'], "should create User card"
    assert_status @newby_email, 'pending'

    integration_login_as 'joe_admin', true
    post :accept, :card=>{:key=>'newby_dooby'}, :email=>{:subject=>'hello', :message=>'world'}
    assert_response :redirect
    assert_status @newby_email, 'active'
  end

  def test_signup_without_approval
    Session.as_bot do  #make it so anyone can create accounts (ie, no approval needed)
      create_accounts_rule = Card['*account+*right'].trait_card(:create)
      create_accounts_rule << Card::AnyoneID
      create_accounts_rule.save!
    end
    post :signup, @newby_args
    assert_response :redirect
    assert_status @newby_email, 'active'
  end

  def test_dont_let_blocked_user_signin
    u = User.find_by_email('u3@user.com')
    u.blocked = true
    u.save
    post :signin, :login => 'u3@user.com', :password => 'u3_pass'
    assert_response 403
    assert_template ('signin')
  end

  def test_forgot_password
    post :forgot_password, :email=>'u3@user.com'
    assert_response :redirect
  end

  def test_forgot_password_not_found
    post :forgot_password, :email=>'nosuchuser@user.com'
    assert_response 404
  end

  def test_forgot_password_blocked
    email = 'u3@user.com'
    Session.as_bot do
      u = User.find_by_email(email)
      u.status = 'blocked'
      u.save!
    end
    post :forgot_password, :email=>email
    assert_response 403
  end

end
