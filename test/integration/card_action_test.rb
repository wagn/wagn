require File.dirname(__FILE__) + '/../test_helper'

require 'card_controller'

class CardController 
  def rescue_action(e) raise e end 
end


class CardActionTest < ActionController::IntegrationTest
   
  include LocationHelper
  
  def setup
    super
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
      Card.create :name=>'A+*self+*comment', :type=>'Pointer', :content=>'[[Anyone]]'
    end
    post "card/comment/A", :card => { :comment=>"how come" }
    assert_response :success
  end

  def test_create_role_card   
    integration_login_as :admin
    post( 'card/create', :card=>{:content=>"test", :type=>'Role', :name=>"Editor"})
    assert_response 418

    assert Card.find_by_name('Editor').typecode == 'Role'
    assert_instance_of Role, Role.find_by_codename('Editor')
  end

  def test_create_cardtype_card
    post( 'card/create','card'=>{"content"=>"test", :type=>'Cardtype', :name=>"Editor2"} )
    assert_response 418
    assert Card.find_by_name('Editor2').typecode == 'Cardtype'
    assert_instance_of Cardtype, Cardtype.find_by_class_name('Editor2')
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


  def test_newcard_shows_edit_instructions
    given_cards( 
      {"Cardtype:YFoo" => ""},
      {"YFoo+*type+*edit help"  => "instruct-me"}
    )
    get 'card/new', :card => {:type=>'YFoo'}
    assert_tag :tag=>'div', :attributes=>{ :class=>"instruction" },  :content=>/instruct-me/ 
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
    assert_tag :tag=>'div', :attributes=>{:class=>'error', :id=>'no-cardtype-error'}
  end

  # FIXME: this should probably be files in the spot for a remove test
  def test_removal_and_return_to_previous_undeleted_card_after_deletion
    t1 = t2 = nil
    User.as(:wagbot) do 
      t1 = Card.create! :name => "Testable1", :content => "hello"
      t2 = Card.create! :name => "Testable1+bandana", :content => "world"
    end

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
