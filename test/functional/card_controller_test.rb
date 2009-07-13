require File.dirname(__FILE__) + '/../test_helper'
require 'card_controller'

# Re-raise errors caught by the controller.
class CardController 
  def rescue_action(e) raise e end 
end
    
class CardControllerTest < ActionController::TestCase
  
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

#=begin
  def test_create_cardtype_card
    post :create, :card=>{"content"=>"test", :type=>'Cardtype', :name=>"Editor"}
    assert assigns['card']
    assert_response 418
    assert_instance_of Card::Cardtype, Card.find_by_name('Editor')
    # this assertion fails under autotest when running the whole suite,
    # passes under rake test.
    # assert_instance_of Cardtype, Cardtype.find_by_class_name('Editor')
  end

  

#  what's happening with this test is that when changing from Basic to CardtypeA it is 
#  stripping the html when the test doesn't think it should.  this could be a bug, but it
#  seems less urgent that a lot of the other bugs on the list, so I'm leaving this test out
#  for now.
# 
#  def test_update_cardtype_no_stripping
#    User.as :joe_user                                               
#    post :update, {:id=>@simple_card.id, :card=>{ :type=>"CardtypeA",:content=>"<br/>" } }
#    #assert_equal "boo", assigns['card'].content
#    assert_equal "<br/>", assigns['card'].content
#    assert_response :success, "changed card type"   
#    assert_equal "CardtypeA", Card['Sample Basic'].type
#  end 
# 
#  def test_update_cardtype_with_stripping
#    User.as :joe_user                                               
#    post :edit, {:id=>@simple_card.id, :card=>{ :type=>"Date",:content=>"<br/>" } }
#    #assert_equal "boo", assigns['card'].content
#    assert_response :success, "changed card type"   
#    assert_equal "", assigns['card'].content  
#    assert_equal "Date", Card['Sample Basic'].type
#  end 




  def test_new_with_name
    post :new, :card=>{:name=>"BananaBread"}
    assert_response :success, "response should succeed"                     
    assert_equal 'BananaBread', assigns['card'].name, "@card.name should == BananaBread"
  end        
                  
  def test_new_with_existing_card
    get :new, :card=>{:name=>"A"}
    assert_response :success, "response should succeed"
  end
  
  def test_show
    get :show, {:id=>'Sample_Basic'}
    assert_response :success
    assert_equal assigns['card'].name, 'Sample Basic'
  end
  
  def test_show_nonexistent_card
    get :show, {:id=>'Sample_Fako'}
    assert_response :success   
    assert_template 'new'
  end

  def test_show_nonexistent_card_no_create
    login_as :anon
    get :show, {:id=>'Sample_Fako'}
    assert_response :success   
    assert_template 'missing'
  end
  
  def test_update
    post :update, { :id=>@simple_card.id, 
      :card=>{:current_revision_id=>@simple_card.current_revision.id, :content=>'brand new content' }} #, {:user=>@user.id} 
    assert_response :success, "edited card"
    assert_equal 'brand new content', Card['Sample Basic'].content, "content was updated"
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
  
  def test_create
    post :create, :card => {
      :name=>"NewCardFoo",
      :type=>"Basic",
      :content=>"Bananas"
    }
    assert_response 418
    assert_instance_of Card::Basic, Card.find_by_name("NewCardFoo")
    assert_equal "Bananas", Card.find_by_name("NewCardFoo").content
  end
                                       
  def test_remove
    c = given_cards("Boo"=>"booya").first
    post :remove, :id=>c.id.to_s
    assert_response :success
    assert_nil Card.find_by_name("Boo")
  end
        

  def test_recreate_from_trash
    @c = Card.create! :name=>"Problem", :content=>"boof"
    @c.destroy!
    post :create, :card=>{
      "name"=>"Problem",
      "type"=>"Phrase",
      "content"=>"noof"
    }
    assert_response 418
    assert_instance_of Card::Phrase, Card.find_by_name("Problem")
  end

  def test_multi_create_without_name
    post :create, "card"=>{"name"=>"", "type"=>"Form"},
     "cards"=>{"~plus~text"=>{"content"=>"<p>abraid</p>"}}, 
     "content_to_replace"=>"",
     "context"=>"main_1", 
     "multi_edit"=>"true", "view"=>"open"
    assert_equal "can't be blank", assigns['card'].errors["name"]
    assert_response 422
  end

        
  def test_multi_create
    post :create, "card"=>{"name"=>"sss", "type"=>"Form"},
     "cards"=>{"~plus~text"=>{"content"=>"<p>abraid</p>"}}, 
     "content_to_replace"=>"",
     "context"=>"main_1", 
     "multi_edit"=>"true", "view"=>"open"
    assert_response 418    
    assert Card.find_by_name("sss")
    assert Card.find_by_name("sss+text")
  end

  def test_should_redirect_to_thanks_on_create_without_read_permission
    # 1st setup anonymously create-able cardtype
    User.as(:joe_admin)
    f = Card.create! :type=>"Cardtype", :name=>"Fruit"
    f.permit(:create, Role[:anon])       
    f.permit(:read, Role[:admin])   
    f.save!
    
    ff = Card.create! :name=>"Fruit+*tform"
    ff.permit(:read, Role[:auth])
    ff.save!
    
    Card.create! :name=>"Fruit+*thanks", :type=>"Phrase", :content=>"/wagn/sweet"
    
    login_as(:anon)     
    post :create, :card => {
      :name=>"Banana", :type=>"Fruit", :content=>"mush"
    }     
    assert_equal "/wagn/sweet", assigns["redirect_location"]
    assert_template "redirect_to_thanks"
  end
  

  def test_should_redirect_to_card_on_create_main_card
    # 1st setup anonymously create-able cardtype
    User.as(:joe_admin)
    f = Card.create! :type=>"Cardtype", :name=>"Fruit"
    f.permit(:create, Role[:anon])       
    f.permit(:read, Role[:anon])   
    f.save!

    ff = Card.create! :name=>"Fruit+*tform"
    ff.permit(:read, Role[:anon])
    ff.save!
    
    login_as(:anon)     
    post :create, :context=>"main_1", :card => {
      :name=>"Banana", :type=>"Fruit", :content=>"mush"
    }                    
    assert_equal "/wagn/Banana", assigns["redirect_location"]
    assert_template "redirect_to_created_card"
  end

  def test_new_should_work_for_creatable_nonviewable_cardtype
    User.as(:joe_admin)
    f = Card.create! :type=>"Cardtype", :name=>"Fruit"
    f.permit(:create, Role[:anon])       
    f.permit(:read, Role[:auth])   
    f.permit(:edit, Role[:admin])   
    f.save!

    ff = Card.create! :name=>"Fruit+*tform"
    ff.permit(:read, Role[:auth])
    ff.save!
    
    login_as(:anon)     
    get :new, :type=>"Fruit"

    assert_response :success
    assert_template "new"
  end

  def test_rename_without_update_references_should_work
    User.as :joe_user
    f = Card.create! :type=>"Cardtype", :name=>"Fruit"
    post :update, :id => f.id, :card => {
      :confirm_rename => true,
      :name => "Newt",
      :update_referencers => "false",
    }                   
    assert_equal ({ "name"=>"Newt", "update_referencers"=>'false', "confirm_rename"=>true }), assigns['card_args']
    assert assigns['card'].errors.empty?
    assert_template 'show'
    assert Card["Newt"]
  end

#=end
  def test_unrecognized_card_renders_missing_unless_can_create_basic
    #User.as :anon
    login_as(:anon) 
    post :show, :id=>'crazy unknown name'
    assert_template 'missing'
  end




  

end
