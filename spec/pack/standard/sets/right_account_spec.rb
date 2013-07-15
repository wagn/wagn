# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card do
  before do
    #Account.as(Card::WagnBotID) # FIXME: as without a block is deprecated
    @account_card = Card['sara'].fetch(:trait=>:account)
  end

  describe "Read and write card attribute" do
    it "gets email attribute" do
      @account_card.real_email.should == 'sara@user.com'
    end

    it "sets and saves email attribute" do
      @account_card.real_email= 'NewSara@user.com'
      @account_card.real_email.should == 'NewSara@user.com'
      #@account_card.accept( @account_card.trunk, {:subject => "test accept", :message=>"you're in"} )
      @account_card.pending?.should be_false
      Account.as_bot { @account_card.save }
      Rails.logger.warn "card #{@account_card.inspect}, #{@account_card.content}, #{@account_card.errors.map { |k,v| "error #{k} :: #{v}" }}"
      Card.cache.reset
      @account_card = Card['sara'].fetch(:trait=>:account)
      @account_card.real_email.should == 'newsara@user.com'
    end
  end
end
