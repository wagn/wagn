require File.expand_path('../../test_helper', File.dirname(__FILE__))
class Card::BaseTest < ActiveSupport::TestCase

  def setup
    super
    Account.as(cid=Card['u3'].id)  # FIXME!!! wtf?  this works and :admin doesn't
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
    Account.as(:joe_user)
    assert c=Card.fetch("u1+*email")
    assert_equal false, c.ok?(:read)
  end

  def test_autocard_should_not_break_if_extension_missing
    assert_equal '', Wagn::Renderer.new(Card.fetch("A+*email")).render_raw
  end
end
