require File.dirname(__FILE__) + '/../test_helper'

require 'card_controller'

class CardController 
  def rescue_action(e) raise e end 
end


class CardActionTest < ActionController::IntegrationTest
   
  include LocationHelper
  
  def setup
    setup_default_user
    integration_login_as :joe_user
  end    

  # Has Test
  # ---------                                                                                   
  # card/remove
  # card/create
  # connection/create
  # card/comment 
  # 
  # FIXME: Needs Test
  # -----------
  # card/rollback
  # card/save_draft
  # connection/remove ??

  def test_comment      
    User.as(:wagbot)  do
      @a = Card.find_by_name("A")  
      @a.permit('comment', Role.find_by_codename('anon'))
      @a.save!
    end
    post "card/comment/#{@a.id}", :card => { :comment=>"how come" }
    assert_response :success
  end      
  
  def test_create_role_card   
    integration_login_as :admin
    post( 'card/create', :card=>{:content=>"test", :type=>'Role', :name=>"Editor"})
    assert_response 418
    assert_instance_of Card::Role, Card.find_by_name('Editor')
    assert_instance_of Role, Role.find_by_codename('Editor')
  end

  def test_create_cardtype_card
    post( 'card/create','card'=>{"content"=>"test", :type=>'Cardtype', :name=>"Editor"} )
    assert_response 418
    assert_instance_of Card::Cardtype, Card.find_by_name('Editor')
    assert_instance_of Cardtype, Cardtype.find_by_class_name('Editor')
  end

  def test_create                   
    post 'card/create', :card=>{
      :type=>'Basic', 
      :name=>"Editor",
      :content=>"testcontent2"
    }
    assert_response 418
    assert_equal "testcontent2", Card["Editor"].content
  end

  
  def test_comment
    @a = Card.find_by_name("A")  
    User.as :wagbot  do
      @a.permit :comment, Role.find_by_codename('anon')
      @a.save
    end
    post "card/comment/#{@a.id}", :card => { :comment=>"how come" }
    assert_response :success
  end 


  def test_newcard_shows_edit_instructions
    given_cards( 
      {"Cardtype:YFoo" => ""},
      {"Set:All YFoo" => '{"type":"YFoo"}'},
      {"All YFoo+*edit"  => "instruct-me"}
    )
    get 'card/new', :card => {:type=>'YFoo'}
    assert_tag :tag=>'div', :attributes=>{ :class=>"custom-instructions instruction" },  :content=>/instruct-me/ 
  end

  def test_newcard_works_with_fuzzy_renamed_cardtype
    given_cards "Cardtype:ZFoo" => ""
    User.as(:joe_user) do
      Card["ZFoo"].update_attributes! :name=>"ZFooRenamed", :update_referencers=>true
    end
    
    get 'card/new', :card => { :type=>'z_foo_renamed' }       
    assert_response :success
  end                                        
  
  def test_newcard_gives_reasonable_error_for_invalid_cardtype
    get 'card/new', :card => { :type=>'bananamorph' }       
    assert_response :success
    assert_tag :tag=>'p', :attributes=>{:class=>'error', :id=>'no-cardtype-error'}
  end


  # FIXME: this should probably be files in the spot for a remove test
  def test_removal_and_return_to_previous_undeleted_card_after_deletion
    t1, t2 = given_cards( 
      { "Testable1" => "hello" }, 
      { "Testable1+*banana" => "world" } 
    )
    
    get url_for_page( t1.name )
    get url_for_page( t2.name )
    
    post 'card/remove/' + t2.id.to_s
    assert_rjs_redirected_to url_for_page( t1.name )   
    assert_nil Card.find_by_name( t2.name )
    
    post 'card/remove/' + t1.id.to_s
    assert_rjs_redirected_to '/'
    assert_nil Card.find_by_name( t1.name )
  end

end
