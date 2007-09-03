require File.dirname(__FILE__) + '/../test_helper'
require 'card_controller'

# Re-raise errors caught by the controller.
class CardController; def rescue_action(e) raise e end; end

class InvitationRequestTest < Test::Unit::TestCase    
  
  include AuthenticatedTestHelper
  
  def setup
    test_renderer
    @controller = CardController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_should_send_notification    
    System.invite_request_alert_email = 'test@user.com' if System.invite_request_alert_email.blank?
    assert_difference ActionMailer::Base.deliveries, :size do
      post :create, :card => {
        :type=>"InvitationRequest", 
        :name=>"Word Third",
        :email=>"jamaster@jay.net", 
        :content=>"Let me in!"
      }  
    end     
    url = ActionMailer::Base.deliveries[-1].body.match(/visit (http:\S+)/)[1]
    assert_equal @controller.url_for_page("Word Third", :host=>System.host), url
  end
  
  def test_should_redirect_to_invitation_request_landing_card 
    post :create, :card=>{
      :type=>"InvitationRequest",
      :name=>"Word Third",
      :email=>"jamaster@jay.net",
      :content=>"Let me in!"
    }  
    # FIXME: the form submits via ajax, so we can't do a regular redirect-- it does javascript
    #  instead.. how do we test that?     
    assert_response :success
    #assert_redirected_to @controller.url_for_page(::Setting.find_by_codename('invitation_request_landing').card.name)
  end
  
  
  def test_should_create_invitation_request  
    post :create, :card=>{
      :type=>"InvitationRequest", 
      :name=>"Word Third", 
      :email=>"jamaster@jay.net", 
      :content=>"Let me in!"
    }  

    @card =  Card.find_by_name("Word Third")   
    @user = @card.extension
    
    assert_instance_of Card::InvitationRequest, @card
    assert_instance_of ::User, @user
    assert_equal 'jamaster@jay.net', @user.email
    assert_equal 'request', @user.status
    
  end
  
  def test_should_destroy_and_block_user  
    # FIXME: should test agains mocks here, instead of re-testing the model...
    post :remove, :id=>Card.find_by_name('Ron Request').id
    assert_equal nil, Card.find_by_name('Ron Request')
    assert_equal 'blocked', ::User.find_by_email('ron@request.com').status

  end
  
end
