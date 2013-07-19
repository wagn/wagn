# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

module Card::Set::Right::Account
  Card::Set.register_set self
  extend Card::Set

  def approve_delete
    deny_because("not allowed to delete card a")
  end

  card_accessor :status,              :default => "request", :type=>:phrase
end

describe Card do
  before do
    #Account.as(Card::WagnBotID) # FIXME: as without a block is deprecated
    @account_card = Card['sara'].fetch(:trait=>:account)
  end

  describe "Read and write card attribute" do
    it "gets email attribute" do
      @account_card.status.should == 'request'
    end

    it "sets and saves email attribute" do
      @account_card.status= 'pending'
      @account_card.status.should == 'pending'
      Account.as_bot { @account_card.save }
      Card.cache.reset
      @account_card = Card['sara'].fetch(:trait=>:account)
      @account_card.status.should == 'pending'
    end
  end
end
