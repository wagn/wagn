require File.dirname(__FILE__) + '/../../test_helper'
class Card::BaseTest < ActiveSupport::TestCase
  
  def setup
    super
    ::User.as(:u3)  # FIXME!!! wtf?  this works and :admin doesn't
  end
         
  def test_autocard_should_not_respond_to_tform 
    assert_nil Card.fetch_or_new("u1+*type+*content")
  end
  
  def test_autocard_should_respond_to_ampersand_email_attribute
    c = Card.fetch_or_new("u1+*email")
    assert_equal 'u1@user.com', c.content
  end
  
  def test_autocard_should_not_respond_to_not_templated_or_ampersanded_card
    assert_equal nil, Card.fetch_or_new("u1+email")
  end           

  def test_should_not_show_card_to_joe_user
    ::User.as(:joe_user)
    assert_equal nil, Card.fetch_or_new("u1+*email")
  end
                            
  def test_autocard_should_not_break_if_extension_missing
    assert_nil Card.fetch_or_new("A+*email")
    #assert_equal "", Card.fetch_or_new("A+*email".to_cardname).content
  end
  
  def test_retrieve_extension_attribute
    pending # this probably goes away
    assert_equal 'u1@user.com', Card.retrieve_extension_attribute("u1", "email")
  end
end
