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
    
    Session.as_bot do 
      Card.create(:name=>'Account Request+*type+*captcha', :content=>'0')
    end
  end
  
  def test_should_redirect_to_account_request_landing_card 
    post :create, :user=>{:email=>"jamaster@jay.net"}, :card=>{
      :type=>"Account Request",
      :name=>"Word Third",
      :content=>"Let me in!"
    }  
    assert_response 302
    #assert_redirected_to @controller.url_for_page(::Setting.find_by_codename('account_request_landing').card.name)
  end
  
  def test_should_create_account_request  
    post :create, :user=>{:email=>"jamaster@jay.net"}, :card=>{
      :type=>"Account Request", 
      :name=>"Word Third", 
      :content=>"Let me in!"
    }

    @card =  Card["Word Third"]   
    @user = User.where(:card_id=>@card.id).first
    
    @card.typecode.should == :account_request

    # this now happens only when created via account controller
    
    #assert_instance_of ::User, @user
    #assert_equal 'jamaster@jay.net', @user.email
    #assert_equal 'request', @user.status
    
  end
 
  def test_should_destroy_and_block_user  
    login_as :joe_user
    # FIXME: should test agains mocks here, instead of re-testing the model...
    post :delete, :id=>"~#{Card.fetch('Ron Request').id}"
    assert_equal nil, Card.fetch('Ron Request')
    assert_equal 'blocked', User.find_by_email('ron@request.com').status
  end
 
end
