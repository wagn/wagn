require File.dirname(__FILE__) + '/../test_helper'

class SaneDataTest < Test::Unit::TestCase
  common_fixtures
  
  def test_cardtypes
    assert ::Cardtype.count >= 3 
    
    Cardtype.find(:all).each do |ct|
      assert_instance_of Card::Cardtype, ct.card, "#{ct.class_name} has card"
    end
    Card.find(:all).each do |c|
      assert_instance_of Card::Cardtype, c.cardtype, "#{c.type} #{c.name} has cardtype card"
      assert_instance_of Cardtype, c.cardtype.extension, "#{c.type} #{c.name} cardtype card has extension"
    end
    Role.find(:all).each do |r|
      assert_instance_of Card::Role, r.card, "Role #{r.codename} has extension"
    end
  end
  
  def test_users
    
  end
  
  
end
