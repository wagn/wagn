require File.dirname(__FILE__) + '/../test_helper'
require 'card_controller'

# Re-raise errors caught by the controller.
#class CardController 
#  def rescue_action(e) raise e end 
#end

class CardControllerTest < Test::Unit::TestCase
  common_fixtures
  include AuthenticatedTestHelper

  def setup
    @controller = CardController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new                                
    User.as_admin do
      @simple_card, @combo_card = create_cards %w{ SmartEngine SmartEngine+FirstPage} 
    end
    setup_default_user
    login_as :admin
  end

  def test_first_steps
    actions = %w(view new revision)
    actions.each do |action|
      test_card_action( action )
    end
  end
     

  def test_create
    post :create, :tag=>{:name=>"NewCardFoo"}, :cardtype=>"Basic", :card=>{:content=>"Bananas"}
    assert_response :success
    assert_instance_of Card::Basic, Card.find_by_name("NewCardFoo")
    assert_equal "Bananas", Card.find_by_name("NewCardFoo").content
  end
=begin FIXME
  def test_edit
    post :edit, { :id=>@simple_card.id, :card=>{:old_revision_id=>@simple_card.current_revision.id, :content=>'brand new content' }}, { :user=>@user.id }
    assert_response :success, "edited card"
    @simple_card.reload
    assert_equal 'brand new content', @simple_card.content, "content was updated"
  end
=end
            
  def test_remove
    
  end
  
=begin  
  def test_new
    
  end

  def test_connect
    
  end

  def test_explain_combo
    
  end

  def test_save_combo
    
  end
  
  def test_flip
    
  end
  
  def test_rename
    
  end
  
  def test_revision
    
  end
  
  def test_rollback
    
  end
=end 
  private
  
  def test_card_action( action, options={} )
    setup 
    get action, { :id => @simple_card.id }.merge(options), {:user => @user.id }
    assert_response :success, "#{action} simple card"

    setup
    get action, { :id => @combo_card.id }.merge(options), {:user => @user.id }
    assert_response :success, "#{action} combo card"    
  end

end
