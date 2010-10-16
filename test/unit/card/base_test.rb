require File.dirname(__FILE__) + '/../../test_helper'
class Card::BaseTest < ActiveSupport::TestCase
  
  def setup
    setup_default_user     
    CachedCard.bump_global_seq
  end

  def test_remove
    forba = Card.create! :name=>"Forba"
    torga = Card.create! :name=>"TorgA"
    torgb = Card.create! :name=>"TorgB"
    torgc = Card.create! :name=>"TorgC"
    
    forba_torga = Card.create! :name=>"Forba+TorgA";
    torgb_forba = Card.create! :name=>"TorgB+Forba";
    forba_torga_torgc = Card.create! :name=>"Forba+TorgA+TorgC";
    
    forba.reload #hmmm
    Card['Forba'].destroy!
    assert_nil Card.find_by_name("Forba")
    assert_nil Card.find_by_name("Forba+TorgA")
    assert_nil Card.find_by_name("TorgB+Forba")
    assert_nil Card.find_by_name("Forba+TorgA+TorgC")
    
    # FIXME: this is a pretty dumb test and it takes a loooooooong time
    #while card = Card.find(:first,:conditions=>["type not in (?,?,?) and trash=?", 'InvitationRequest','User','Cardtype',false] )
    #  card.destroy!
    #end
    #assert_equal 0, Card::Basic.find_all_by_trash(false).size
  end

  def test_attribute_card
    alpha, beta = Card.create(:name=>'alpha'), Card.create(:name=>'beta')
    assert_nil alpha.attribute_card('beta')
    Card.create :name=>'alpha+beta'   
    assert_instance_of Card::Basic, alpha.attribute_card('beta')
  end

  def test_create
    alpha = Card::Basic.new :name=>'alpha', :content=>'alpha'
    assert_equal 'alpha', alpha.content
    alpha.save
    assert_stable(alpha)
  end
  
  
  # just a sanity check that we don't have broken data to start with
  def test_fixtures
    Card::Base.find(:all).each do |p|
      assert_instance_of String, p.name
    end
  end

  def test_find_by_name
    card = Card::Basic.create( :name=>"ThisMyCard", :content=>"Contentification is cool" )
    assert_equal card, Card.find_by_name("ThisMyCard")
  end
 
  
  def test_find_nonexistent
    assert !Card.find_by_name('no such card+no such tag')
    assert !Card.find_by_name('HomeCard+no such tag')
  end
          

  def test_multi_update_should_create_subcards  
    User.as(:joe_user)
    b = Card.create!( :name=>'Banana' )
    b.multi_update({ "+peel" => { :content => "yellow" }})
    assert_equal "yellow", Card["Banana+peel"].content   
    assert_equal User[:joe_user].id, Card["Banana+peel"].created_by
  end
  
  def test_multi_update_should_create_subcards_as_wagbot_if_missing_subcard_permissions
    # then repeat multiple update as above, as :anon
    User.as(:anon) 
    b = Card.create!( :type=>"Fruit", :name=>'Banana' )
    b.multi_update({ "+peel" => { :content => "yellow" }})
    assert_equal "yellow", Card["Banana+peel"].current_revision.content   
    assert_equal User[:wagbot].id, Card["Banana+peel"].created_by
  end
  
  def test_multi_update_should_not_create_cards_if_missing_main_card_permissions
    User.as(:joe_user)
    b = Card.create!( :name=>'Banana' )
    User.as(:anon) 
    assert_raises( Card::PermissionDenied ) do
      b.multi_update({ "+peel" => { :content => "yellow" }})
    end
  end


  def test_create_without_read_permission
    User.as(:anon)     
    c = Card.create! :name=>"Banana", :type=>"Fruit", :content=>"mush"
    assert_raises Card::PermissionDenied do
      Card['Banana'].content
    end
  end
  

  private 
    def assert_simple_card( card )
      assert !card.name.nil?, "name not null"
      assert !card.name.empty?, "name not empty"
      assert_instance_of Revision, card.current_revision
      #assert_instance_of User, card.created_by
    end
    
    def assert_samecard( card1, card2 )
      assert_equal card1.current_revision, card2.current_revision
      assert_equal card1.tag, card2.tag
    end
   
    def assert_stable( card1 )
      card2 = Card.find_by_name(card1.name)
      assert_simple_card( card1 )
      assert_simple_card( card2 )
      assert_samecard( card1, card2 )
    end
end

