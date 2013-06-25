# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card do
  before do
    #Account.as(Card::WagnBotID) # FIXME: as without a block is deprecated
    @account_card = Card['sara'].fetch(:trait=>:account)
  end

  describe "Read and write card attribute" do
    it "gets email attribute" do
      @account_card.email.should == '' #FIXME: migrate data to cards and test for real value
    end

    it "sets and saves email attribute" do
      @account_card.email= 'NewSara@user.com'
      @account_card.email.should == 'NewSara@user.com'
      Account.as_bot { @account_card.save }
      warn "card #{@account_card.inspect}, #{@account_card.errors.map { |k,v| "error #{k} :: #{v}" }}"
      Card.cache.reset
      @account_card = Card['sara'].fetch(:trait=>:account)
      @account_card.email.should == 'NewSara@user.com'
    end
  end
end
