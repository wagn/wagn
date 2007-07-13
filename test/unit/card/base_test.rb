require File.dirname(__FILE__) + '/../../test_helper'
class Card::BaseTest < Test::Unit::TestCase
  common_fixtures
  def setup
    setup_default_user
  end

  def test_should_create_connection_card
    Card::Basic.create!(
      :trunk => Card.find_by_name('Joe User'),
      :tag => Card.find_by_name('color').tag,
      :content=>'green'
     )
     assert_instance_of Card::Basic, Card.find_by_name("Joe User+color")
  end

  def test_connect
    alpha, beta = newcard('alpha'),newcard('beta')
    alpha_beta = alpha.connect beta
    assert_equal "alpha"+JOINT+"beta", alpha_beta.name
  end
        
  def test_attribute_card
    alpha, beta = newcard('alpha'),newcard('beta')
    assert_nil alpha.attribute_card('beta')
    alpha.connect beta
    assert_instance_of Card::Basic, alpha.attribute_card('beta')
    assert_equal "alpha"+JOINT+"beta",alpha.attribute_card('beta').name
  end

  def test_create
    alpha = Card::Basic.new :name=>'alpha', :content=>'alpha'
    assert_equal 'alpha', alpha.content
    alpha.save
    assert_stable(alpha)
  end
  
  def test_create_from_existing_tag
    tag = Tag.create :name=>'RipeBananas'
    alpha = Card::Basic.new :tag=>tag
    assert alpha.save
    assert_stable(alpha)
  end
 
  def test_remove
    forba = newcard "Forba"
    torga = newcard "TorgA"
    torgb = newcard "TorgB"
    torgc = newcard "TorgC"
    
    forba_torga = forba.connect( torga )  # Forba#{JOINT}TorgA
    torgb_forba = torgb.connect( forba )  # TorgB#{JOINT}Forba
    forba_torga_torgc = forba_torga.connect( torgc ) # Forba#{JOINT}TorgA#{JOINT}TorgC
    
    forba.reload #hmmm
    forba.destroy
    assert_nil Card.find_by_name("Forba")
    assert_nil Card.find_by_name("Forba#{JOINT}TorgA")
    assert_nil Card.find_by_name("TorgB#{JOINT}Forba")
    assert_nil Card.find_by_name("Forba#{JOINT}TorgA#{JOINT}TorgC")
    
    
    while card = Card.find(:first,:conditions=>["type not in (?,?)", 'User','Cardtype'] )
      card.destroy
    end
    assert_equal 0, Card::Basic.count
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

    
  def test_add_tag_standard_order
    Card::Basic.create( :name=>"TwoThirty", :content=>"" )
    @tag = Tag.find_by_name("TwoThirty")
    @newcard = Card.find_by_name('Wagn').add_tag(@tag)
    assert_equal @newcard, Card.find_by_tag_id_and_trunk_id(@tag.id,Card.find_by_name('Wagn').id), "find connection"
    assert_equal User.current_user, @newcard.created_by
  end

  def test_add_tag_duplicate
    Card::Basic.create( :name=>"Two", :content=>"" )
    @tag = Tag.find_by_name("Two")
    @newcard =  Card.find_by_name('Wagn').add_tag(@tag)
    assert_equal @newcard, Card.find_by_tag_id_and_trunk_id(@tag.id,Card.find_by_name('Wagn').id)

    @tag = Tag.find_by_name("Two")
    @newcard = Card.find_by_name('Wagn').add_tag(@tag)
    assert_equal @newcard, Card.find_by_tag_id_and_trunk_id(@tag.id,Card.find_by_name('Wagn').id)
  
    assert_equal 1, Tag.find_all_by_name("Two").length
  end

  def tag_connecting
    apple,orange,banana = newcard('apple'),newcard('orange'),newcard('banana')
    apple_banana = apple.connect banana
    assert_equal apple_banana, banana.connect(apple)
    assert_raises Wagn::Oops, banana.connect!(apple)
  end
  
  
  def test_find_nonexistent
    assert !Card.find_by_name('no such card#{JOINT}no such tag')
    assert !Card.find_by_name('HomeCard#{JOINT}no such tag')
  end

  private 
    def assert_simple_card( card )
      assert !card.name.nil?, "name not null"
      assert !card.name.empty?, "name not empty"
      assert_instance_of Revision, card.current_revision
      assert_instance_of Tag, card.tag
      assert_instance_of TagRevision, card.tag.current_revision
      assert_instance_of User, card.created_by
      assert_equal card, card.tag.root_card
    end
    
    def assert_samecard( card1, card2 )
      assert_equal card1.current_revision, card2.current_revision
      assert_equal card1.tag, card2.tag
      assert_equal card1.tag.current_revision, card2.tag.current_revision
    end
   
    def assert_stable( card1 )
      card2 = Card.find_by_name(card1.name)
      assert_simple_card( card1 )
      assert_simple_card( card2 )
      assert_samecard( card1, card2 )
    end

end

