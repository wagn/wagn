# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card::Set::Type::AccountRequest do
  it "should have a special section for approving requests" do
    card = Card.create!(:name=>'Big Bad Wolf', :type=>'Account Request')
    assert_view_select Card::Format.new(card).render(:core), 'div[class="invite-links"]'
  end
end
