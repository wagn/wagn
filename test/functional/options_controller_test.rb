require File.dirname(__FILE__) + '/../test_helper'
require 'options_controller'

# Re-raise errors caught by the controller.
class OptionsController 
  def rescue_action(e) raise e end 
end

class OptionsControllerTest < Test::Unit::TestCase
  common_fixtures
  include AuthenticatedTestHelper

  def setup
    User.as :admin
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new                                
    @controller = OptionsController.new
    login_as(:admin)
  end    




  def test_should_create_account_from_scratch
    assert_difference ActionMailer::Base.deliveries, :size do 
      post :create_account, :extension=>{:email=>'foo@bar.com', :password=>'p8ssw0rd', :password_confirmation=>'p8ssw0rd'}, :id=>'a'
      assert_response 200
    end
    email = ActionMailer::Base.deliveries[-1]      
    # emails should be 'from' inviting user
    #assert_equal User.current_user.email, email.from[0]  
    #assert_equal 'active', User.find_by_email('new@user.com').status
    #assert_equal 'active', User.find_by_email('new@user.com').status
  end


end
