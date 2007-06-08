require File.dirname(__FILE__) + '/../../test_helper'
class Card::CardtypeTest < Test::Unit::TestCase
  common_fixtures
  def setup
    setup_default_user
  end
  
  def test_remove
    city = Card::Cardtype.create :name=>'City'
    Card::City.create :name=>'Sparta'
    Card::City.create :name=>'Eugene'
    assert_equal ['Eugene','Sparta'], city.cards_of_this_type.plot(:name).sort
    assert_raises Wagn::Oops do
      city.destroy
    end
  end
  
  def test_remove_cardtype
    city = Card::Cardtype.create :name=>'City'
    city.destroy
    assert_nil Cardtype.find_by_class_name('City')
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
  
  def test_class_name
    assert_equal 'Basic', Card::Basic.find(:first).class_name
  end
  
  
  def test_cardtype
    Card.find(:all).each do |card|
      assert_instance_of Card::Cardtype, card.cardtype
    end
  end
  
end
