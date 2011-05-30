require File.dirname(__FILE__) + '/../test_helper'
require 'card_controller'

# Re-raise errors caught by the controller.
class CardController; def rescue_action(e) raise e end; end
class InvitationRequestTest < ActionController::TestCase    
  
  include AuthenticatedTestHelper
  
  def setup
    super
    get_renderer
    @controller = CardController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    User.as :wagbot do 
      Card.create(:name=>'Account Request+*type+*captcha', :content=>'0')
    end
  end
  
 

  def test_should_redirect_to_invitation_request_landing_card 
    post :create, :card=>{
      :type=>"Account Request",
      :name=>"Word Third",
      :account=>{:email=>"jamaster@jay.net"},
      :content=>"Let me in!"
    }  
    assert_response 418
    #assert_redirected_to @controller.url_for_page(::Setting.find_by_codename('invitation_request_landing').card.name)
  end
  
  
  def test_should_create_invitation_request  
    post :create, :card=>{
      :type=>"Account Request", 
      :name=>"Word Third", 
      :account=>{:email=>"jamaster@jay.net"},
      :content=>"Let me in!"
    }  

    @card =  Card.find_by_name("Word Third")   
    @user = @card.extension
    
    assert_instance_of Card::InvitationRequest, @card

    # this now happens only when created via account controller
    
    #assert_instance_of ::User, @user
    #assert_equal 'jamaster@jay.net', @user.email
    #assert_equal 'request', @user.status
    
  end
 
  def test_should_destroy_and_block_user  
Rails.logger.info("failing 1")
    login_as :joe_user
    # FIXME: should test agains mocks here, instead of re-testing the model...
    post :remove, :id=>Card.find_by_name('Ron Request').id
    assert_equal nil, Card.find_by_name('Ron Request')
    assert_equal 'blocked', ::User.find_by_email('ron@request.com').status
Rails.logger.info("failing 2")
  end
  
=begin DOES NOT AUTOMATICALLY HAPPEN ANY MORE.
   def test_should_send_notification
      User.as :wagbot  do
        Card.create :name=>'*invite+*to', :content=> 'test@user.com'
      end
  #    System.invite_request_alert_email = 'test@user.com' if System.invite_request_alert_email.blank?
      assert_difference ActionMailer::Base.deliveries, :size do
        post :create, :card => {
          :type=>"InvitationRequest", 
          :name=>"Word Third",
          :account=>{:email=>"jamaster@jay.net"},
          :content=>"Let me in!"
        }  
      end     
      mail = ActionMailer::Base.deliveries[-1]
      pattern = /(http:[^\"]+)/
      assert_match pattern, mail.body
      mail.body =~ pattern
      assert_equal "http://#{System.host}#{@controller.send(:url_for_page, "Word Third")}", $~[0]
    end
=end
end
