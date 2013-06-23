# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe "card search" do

  before do
    Account.current_id = Card['u3'].id
  end

  def test_autocard_should_not_respond_to_tform
    Card.fetch("u1+*type+*structure").should_not be
  end

  def test_autocard_should_respond_to_ampersand_email_attribute
    (card = Card.fetch "u1+*email", :new=>{}).should be

    Card::Format.new(card).render_raw.should == 'u1@user.com'
  end

  def test_autocard_should_not_respond_to_not_templated_or_ampersanded_card
    Card.fetch( "u1+email" ).should_not be
  end

  def test_should_not_show_card_to_joe_user
    # FIXME: this needs some permission rules
    Account.as 'joe user' do
      card = Card.fetch("u1+*email").should be
      card.ok?(:read).should be_false
    end
  end

  def test_autocard_should_not_break_if_extension_missing
    Card::Format.new( Card.fetch "A+*email" ).render_raw.should == ''
  end
end
