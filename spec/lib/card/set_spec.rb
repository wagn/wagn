# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

module Card::Set::Right::Account
  Card::Set.register_set self
  extend Card::Set

  def approve_delete
    deny_because("not allowed to delete card a")
  end

  card_accessor :status,              :default => "request", :type=>:phrase
  card_writer :write,                 :default => "request", :type=>:phrase
  card_reader :read,                  :default => "request", :type=>:phrase
end

describe Card do
  before do
    #Account.as(Card::WagnBotID) # FIXME: as without a block is deprecated
    @account_card = Card['sara'].fetch(:trait=>:account)
  end

  describe "Read and write card attribute" do
    it "gets email attribute" do
      @account_card.status_field.should == 'request'
    end

    it "shouldn't have a reader method for card_writer" do
      @account_card.respond_to?( :write_field ).should be_false
      @account_card.method( :write_field= ).should be
    end

    it "shouldn't have a reader method for card_reader" do
      @account_card.method( :read_field ).should be
      @account_card.respond_to?( :read_field= ).should be_false
    end

    it "sets and saves attribute" do
      @account_card.write_field= 'test_value'
      @account_card.status_field= 'pending'
      @account_card.status_field.should == 'pending'
      Account.as_bot { @account_card.save }
      Card.cache.reset
      (tcard = Card['sara'].fetch(:trait=>:account)).should be
      tcard.status_field.should == 'pending'
      tcard.fetch(:trait=>:write).content.should == 'test_value'
    end
  end
end
