require File.dirname(__FILE__) + '/../../test_helper'
class Card::CardtypeTest < ActiveSupport::TestCase
  
  def setup
    setup_default_user
  end
  
  def test_should_not_allow_cardtype_remove_when_instances_present
    Card::Cardtype.create :name=>'City'
    city = Card::Cardtype.find_by_name('City')
    Card::City.create :name=>'Sparta'
    Card::City.create :name=>'Eugene'
    assert_equal ['Eugene','Sparta'], Card.search(:type=>'City').plot(:name).sort
    assert_raises Wagn::Oops do
      city.destroy!
    end                             
    # make sure it wasn't destroyed / trashed
    assert Card.find_by_name('City')
  end
  
  def test_remove_cardtype
    Card::Cardtype.create! :name=>'County'
    city = Card::Cardtype.find_by_name('County')
    #warn "extension: #{city.extension}"
    city.destroy
    assert_nil Cardtype.find_by_class_name('County')
  end
  
  def test_cardtype_creation_and_dynamic_cardtype
    assert_raises( NameError ) do
      Card::BananaPudding.create :name=>"figgy"
    end
    assert_instance_of Card::Cardtype, Card::Cardtype.create( :name=>'BananaPudding' )
    assert_instance_of Cardtype, Card.find_by_name("BananaPudding").extension
    assert_instance_of Cardtype, Cardtype.find_by_class_name("BananaPudding")    
    assert_instance_of Card::BananaPudding, Card::BananaPudding.create( :name=>"figgy" )
  end
  
  def test_conversion_to_cardtype
    card = Card.create!(:name=>'Cookie')
    assert_equal 'Basic', card.type
    card.type = 'Cardtype'
    card.save!
    
    card=Card['Cookie']
    assert_instance_of Cardtype, card.extension
    assert_not_nil Permission.find_by_card_id_and_task(card.id, 'create')
    assert_equal 'Cookie', Card.create!( :name=>'Oreo', :type=>'Cookie' ).type
  end
  
  def test_cardtype
    Card.find(:all).each do |card|
      assert_instance_of Card::Cardtype, card.cardtype
    end
  end
  
end
