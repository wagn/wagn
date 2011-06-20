require File.dirname(__FILE__) + '/../test_helper'

class SaneDataTest < ActiveSupport::TestCase
  
  
  def test_cardtypes
    assert ::Cardtype.count >= 3 
    
    Cardtype.find(:all).each do |ct|
      assert ct.card.class.include?(Card::Cardtype), "#{ct.class_name} has card"
    end
    Card.find(:all).each do |c|
      assert ct.cardtype.class.include?(Card::Cardtype), "#{c.cardtype} #{c.name} has cardtype card"
      assert_instance_of Cardtype, c.cardtype.extension, "#{c.cardtype} #{c.name} cardtype card has extension"
    end
    Role.find(:all).each do |r|
      assert_instance_of Card::Role, r.card, "Role #{r.codename} has extension"
    end
  end
  
  def test_users
    
  end
  
  
end
