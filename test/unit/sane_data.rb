require File.expand_path('../test_helper', File.dirname(__FILE__))

class SaneDataTest < ActiveSupport::TestCase


  def test_cardtypes
    assert Session.createable_types.size >= 3

    Card.find(:all).each do |ct|
      if ct.codename == :cardtype
        assert ct.card.class.include?(Wagn::Set::Type::Cardtype), "#{ct.class_name} has card"
      end
    end
    #Card.find(:all).each do |c|
    #  assert ct.cardtype.class.include?(Wagn::Set::Type::Cardtype), "#{c.cardtype} #{c.name} has cardtype card"
    #  assert_instance_of Cardtype, c.cardtype.extension, "#{c.cardtype} #{c.name} cardtype card has extension"
    #end
    Role.find(:all).each do |r|
      assert r.card.cardtype.class.include?(Wagn::Set::Type::Role), "Role #{r.codename} has extension"
    end
  end

  def test_users

  end


end
