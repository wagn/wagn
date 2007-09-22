require File.dirname(__FILE__) + '/../test_helper'
#require 'ruby-prof'


class CardActionTest < ActionController::IntegrationTest
  common_fixtures 
  warn "LOADING CARD ACTION TEST"
  
  def setup
    setup_default_user
    login_as :joe_user
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

  
  def test_card_removal2
    boo = newcard "Boo", "booya"
    sidebar = newcard "*sidebar"
    open = newcard "*open"
    connect( boo, sidebar, "200")
    boo_open = connect( boo, open )
    
    post 'card/remove/' + boo_open.id.to_s
    assert_response :success
    assert_nil Card.find_by_name("Boo#{JOINT}*open")
  end
  
  def test_connect
    apple = newcard("Apple", "woot")
    orange = newcard("Orange", "wot")
    assert_instance_of Card::Basic, connect( apple, orange  )
    assert_instance_of Card::Basic, Card.find_by_name("Apple#{JOINT}Orange")
  end

  def test_create
    assert_instance_of Card::Basic, newcard("Editor", "testcontent and stuff")
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
    c = newcard "Boo", "booya"
    post 'card/remove/' + c.id.to_s
    assert_response :success
    assert_nil Card.find_by_name("Boo")
  end
  
  def test_comment
    @a = Card.find_by_name("A")  
    @a.appender = Role.find_by_codename('anon')
    @a.save
    post "card/comment/#{@a.id}", :card => { :comment=>"how come" }
    assert_response :success
  end 
  
  private
    def newcard( name, content="" )
      post( 'card/create', :card=>{"content"=>content, :type=>'Basic', :name=>name})
      assert_response :success
      Card.find_by_name(name)
    end
    
    def connect( trunk, tag_card, content="" )
      assert tag_card.simple?
      post( 'connection/create', 
        :id => trunk.id,
        :card => { :name=>tag_card.name },
        :connection => { :content=>content })
      assert_response :success
      Card.find_by_name( trunk.name + JOINT + tag_card.name )
    end
 
end
