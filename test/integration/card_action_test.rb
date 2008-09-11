require File.dirname(__FILE__) + '/../test_helper'
#require 'ruby-prof'


class CardActionTest < ActionController::IntegrationTest
  common_fixtures 
  
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
    User.as(:admin) do
      @a = Card.find_by_name("A")  
      @a.permit('comment', Role.find_by_codename('anon'))
      @a.save!
    end
    post "card/comment/#{@a.id}", :card => { :comment=>"how come" }
    assert_response :success
  end      
  

  def test_card_removal2   
    User.as :joe_user
    Card.create! :name=>"Boo+*sidebar+200", :content=>"booya"
    boo_open = Card.create! :name=>'Boo+*open'
    
    post 'card/remove/' + boo_open.id.to_s
    assert_response :success
    assert_nil Card.find_by_name("Boo#{JOINT}*open")
  end        

  def test_connect
    given_cards( "Apple"=>"woot", "Orange" => "wot" )
    apple, orange = Card["Apple"], Card["Orange"]

    post( 'connection/create', :id => apple.id, :name=>orange.name  )
    assert_response :success
    assert_instance_of Card::Basic, Card["Apple+Orange"]
  end

  def test_create                   
    post 'card/create', :card=>{
      :type=>'Basic', 
      :name=>"Editor",
      :content=>"testcontent2"
    }
    assert_response :success
    assert_equal "testcontent2", Card["Editor"].content
  end

  def test_create_role_card
    post( 'card/create', :card=>{:content=>"test", :type=>'Role', :name=>"Editor"})
    assert_response :success
    assert_instance_of Card::Role, Card.find_by_name('Editor')
    assert_instance_of Role, Role.find_by_codename('Editor')
  end

  def test_create_cardtype_card
    post( 'card/create',:card=>{"content"=>"test", :type=>'Cardtype', :name=>"Editor"} )
    assert_response :success
    assert_instance_of Card::Cardtype, Card.find_by_name('Editor')
    assert_instance_of Cardtype, Cardtype.find_by_class_name('Editor')
  end
  
  def test_card_removal
    c = given_cards("Boo"=>"booya").first
    post 'card/remove/' + c.id.to_s
    assert_response :success
    assert_nil Card.find_by_name("Boo")
  end
  
  def test_comment
    @a = Card.find_by_name("A")  
    User.as :admin do
      @a.permit :comment, Role.find_by_codename('anon')
      @a.save
    end
    post "card/comment/#{@a.id}", :card => { :comment=>"how come" }
    assert_response :success
  end 
       
  

  private   
  
  def given_cards( definitions )   
    User.as(:joe_user) do 
      Card.create_these definitions
    end
  end

end
