require File.expand_path('../test_helper', File.dirname(__FILE__))
require 'options_controller'

# Re-raise errors caught by the controller.
class OptionsController 
  def rescue_action(e) raise e end 
end

class OptionsControllerTest < ActionController::TestCase
  
  include AuthenticatedTestHelper

  def setup
    super
    User.as :wagbot 
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new                                
    @controller = OptionsController.new
    login_as(:wagbot)
  end    

  def test_should_create_account_from_scratch
    assert_difference ActionMailer::Base.deliveries, :size do 
      post :create_account, :user=>{:email=>'foo@bar.com'}, :id=>'a'
      assert_response 200
    end
    email = ActionMailer::Base.deliveries[-1]
    # emails should be 'from' inviting user
    #assert_equal User.current_user.email, email.from[0]  
    #assert_equal 'active', User.find_by_email('new@user.com').status
    #assert_equal 'active', User.find_by_email('new@user.com').status
  end

  def test_update_user_extension_blocked_status
    assert !User.find_by_login('joe_user').blocked?
    post :update, :id=>"Joe User".to_cardname.to_key, :extension => { :blocked => '1' }
    assert User.find_by_login('joe_user').blocked?
    post :update, :id=>"Joe User".to_cardname.to_key, :extension => { :blocked => '0' }
    assert !User.find_by_login('joe_user').blocked?
  end
end
