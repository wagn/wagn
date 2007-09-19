require File.dirname(__FILE__) + '/../test_helper'
require 'card_controller'

# Re-raise errors caught by the controller.
class CardController 
  def rescue_action(e) raise e end 
end

class CardControllerTest < Test::Unit::TestCase
  common_fixtures
  include AuthenticatedTestHelper

  def setup
    User.as :joe_user
    @user = User[:joe_user]
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new                                
    @controller = CardController.new
    @simple_card = Card['Sample Basic']
    @combo_card = Card['A+B']
    login_as(:joe_user)
    
  end     
  
  def test_show
    get :show, {:id=>'Sample_Basic'}
    assert_response :success
    assert_equal assigns['card'].name, 'Sample Basic'
  end
  
  def test_show_nonexistent_card
    get :show, {:id=>'Sample_Fako'}
    assert_redirected_to :action=>'new'
  end

  def test_show_nonexistent_card_no_create
    login_as :anon
    get :show, {:id=>'Sample_Fako'}
    assert_redirected_to :action=>'missing'
  end
  
  def test_update
    post :update, { :id=>@simple_card.id, 
      :card=>{:current_revision_id=>@simple_card.current_revision.id, :content=>'brand new content' }} #, {:user=>@user.id} 
    assert_response :success, "edited card"
    assert_equal 'brand new content', Card['Sample Basic'].content, "content was updated"
  end
  
  def test_update_cardtype
    User.as :joe_user
    post :edit, {:id=>@simple_card.id, :card=>{ :type=>"Currency" }}
    assert_response :success, "changed card type"
    assert_equal "Currency", Card['Sample Basic'].type
  end 
   
  def test_changes
    id = Card.find_by_name('revtest').id
    get :changes, :id=>id, :rev=>1
    assert_equal 'first', assigns['revision'].content, "revision 1 content==first"

    get :changes, :id=>id, :rev=>2
    assert_equal 'second', assigns['revision'].content, "revision 2 content==second"
    assert_equal 'first', assigns['previous_revision'].content, 'prev content=="first"'
  end

  def test_new_without_cardtype
    post :new   
    assert_response :success, "response should succeed"                     
    assert_equal 'Basic', assigns['card'].type, "@card type should == Basic"
  end

  def test_new_with_cardtype
    post :new, :card => {:type=>'Date'}   
    assert_response :success, "response should succeed"                     
    assert_equal 'Date', assigns['card'].type, "@card type should == Date"
  end        
  
  def test_new_with_name
    post :new, :card=>{:name=>"BananaBread"}
    assert_response :success, "response should succeed"                     
    assert_equal 'BananaBread', assigns['card'].name, "@card.name should == BananaBread"
  end        

  def test_create
    post :create, :card => {
      :name=>"NewCardFoo",
      :type=>"Basic",
      :content=>"Bananas"
    }
    assert_response :success
    assert_instance_of Card::Basic, Card.find_by_name("NewCardFoo")
    assert_equal "Bananas", Card.find_by_name("NewCardFoo").content
  end
                                       


  
=begin FIXME

            
  def test_remove
    
  end
  
  def test_new    
  end

  def test_rename
  end
  
  def test_revision
  end
  
  def test_rollback
  end
=end 

  

end
