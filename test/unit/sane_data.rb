require File.dirname(__FILE__) + '/../test_helper'

class SaneDataTest < ActiveSupport::TestCase
  
  
  def test_cardtypes
    assert ::Cardtype.count >= 3 
    
    Cardtype.find(:all).each do |ct|
      assert ct.card.class.include?(Wagn::Model::Type::Cardtype), "#{ct.class_name} has card"
    end
    Card.find(:all).each do |c|
      assert ct.cardtype.class.include?(Wagn::Model::Type::Cardtype), "#{c.cardtype} #{c.name} has cardtype card"
      assert_instance_of Cardtype, c.cardtype.extension, "#{c.cardtype} #{c.name} cardtype card has extension"
    end
    Role.find(:all).each do |r|
      assert r.card.cardtype.class.include?(Wagn::Model::Type::Role), "Role #{r.codename} has extension"
    end
  end
  
  def test_users
    
  end
  
  
end
