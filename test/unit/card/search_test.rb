require File.dirname(__FILE__) + '/../../test_helper'
class Card::BaseTest < ActiveSupport::TestCase
  
  def setup           
    ::User.as(:u3)  # FIXME!!! wtf?  this works and :admin doesn't
  end
         
  def test_autocard_should_not_respond_to_tform 
    assert_nil Card.auto_card("u1+*tform")
  end
  
  def test_autocard_should_respond_to_ampersand_email_attribute
    c = Card.auto_card("u1+*email")
    assert_equal 'u1@user.com', c.content
  end
  
  def test_autocard_should_not_respond_to_not_templated_or_ampersanded_card
    assert_equal nil, Card.auto_card("u1+email")
  end           

  def test_should_not_show_card_to_joe_user
    ::User.as(:joe_user)
    assert_equal nil, Card.auto_card("u1+*email")
  end
                            
  def test_autocard_should_not_break_if_extension_missing
    assert_equal "", Card.auto_card("A+*email").content
  end
  
  def test_retrieve_extension_attribute
    assert_equal 'u1@user.com', Card.retrieve_extension_attribute("u1", "email")
  end
end