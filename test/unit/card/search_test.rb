require File.dirname(__FILE__) + '/../../test_helper'
class Card::BaseTest < ActiveSupport::TestCase
  
  def setup
    super
    ::User.as(:u3)  # FIXME!!! wtf?  this works and :admin doesn't
  end
         
  def test_autocard_should_not_respond_to_tform 
    assert_nil Card.fetch("u1+*type+*content")
  end
  
  def test_autocard_should_respond_to_ampersand_email_attribute
    assert c = Card.fetch_or_new("u1+*email")
    assert_equal 'u1@user.com', Wagn::Renderer.new(c).render_raw
  end
  
  def test_autocard_should_not_respond_to_not_templated_or_ampersanded_card
    assert_nil Card.fetch("u1+email")
  end           

  def test_should_not_show_card_to_joe_user
    # FIXME: this needs some permission rules
    ::User.as(:joe_user)
    assert_equal nil, Card.fetch("u1+*email")
  end
                            
  def test_autocard_should_not_break_if_extension_missing
    assert_nil c=Card['A+*email']
    assert_nil c=Card.fetch("A+*email")
    #assert_equal "", Wagn::Renderer(c).render_raw
  end
end
