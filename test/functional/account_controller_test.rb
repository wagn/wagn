require File.dirname(__FILE__) + '/../test_helper'
require 'user_controller'

# Re-raise errors caught by the controller.
class UserController; def rescue_action(e) raise e end; end

class UserControllerTest < ActionController::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
  include AuthenticatedTestHelper
  
  # Note-- user creation is handled in it's own file user_creation_test

  

  def setup
    get_renderer
    @controller = UserController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @newby_email = 'newby@wagn.net'
    @newby_args =  {:user=>{ :email=>@newby_email },
                    :card=>{ :name=>'Newby Dooby' }}
    User.as :wagbot do 
      Card.create(:name=>'Account Request+*type+*captcha', :content=>'0')
    end
    signout
  end


 # def test_should_login_and_redirect
 #   post :signin, :login => 'u3@user.com', :password => 'u3_pass'
 #   assert session[:user]
 #   assert_response :redirect
 # end
 #
 # def test_should_fail_login_and_not_redirect
 #   post :signin, :login => 'webmaster@grasscommons.org', :password => 'bad password'
 #   assert_nil session[:user]
 #   assert_response 403
 # end
 # 
 # def test_should_signout
 #   get :signout
 #   assert_nil session[:user]
 #   assert_response :redirect
 # end
 #
 # def test_create_successful   
 #   login_as :joe_user
 #   assert_difference ActionMailer::Base.deliveries, :size do 
 #     assert_new_account do 
 #       post_invite
 #     end
 #   end
 # end

  def test_signup_with_approval
    post :signup, @newby_args
    assert_response :redirect
    assert_status @newby_email, 'pending' # active debugger
    
    login_as :joe_user
    post :accept, :card=>{:key=>'newby_dooby'}, :email=>{:subject=>'hello', :message=>'world'}
    assert_response :redirect # 200 debugger
    assert_status @newby_email, 'active'
  end

  def test_signup_without_approval
    User.as :wagbot do  #make it so anyone can create users (ie, no approval needed)
      ne1 = Role[:anon]
      ne1.tasks = 'create_users'
      ne1.save!
    end
    post :signup, @newby_args
    assert_response :redirect
    assert_status @newby_email, 'active'
  end

#  def test_dont_let_blocked_user_signin
#    u = User.find_by_email('u3@user.com')
#    u.blocked = true
#    u.save
#    post :signin, :login => 'u3@user.com', :password => 'u3_pass'
#    assert_response 403 
#    assert_template ('signin')
#  end
#
#  def test_forgot_password
#    post :forgot_password, :email=>'u3@user.com'
#    assert_response :redirect
#  end 
#
#  def test_forgot_password_not_found
#    post :forgot_password, :email=>'nosuchuser@user.com'
#    assert_response 404
#  end                        
#   
#  def test_forgot_password_blocked
#    email = 'u3@user.com'
#    User.as :wagbot do
#      u = User.find_by_email(email)
#      u.status = 'blocked'
#      u.save!
#    end
#    post :forgot_password, :email=>email
#    assert_response 403
#  end                        

end
