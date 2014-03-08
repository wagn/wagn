# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

module Card::Set::Right::Account # won't this conflict with a real set (and fail to provide controlled test?)
  extend Card::Set

  card_accessor :role,   :default => "request", :type=>:phrase
  card_writer   :write,  :default => "request", :type=>:phrase
  card_reader   :read,   :default => "request", :type=>:phrase
end

describe Card do
  before do
    @account_card = Card['sara'].fetch :trait=>:account
  end

  describe "Read and write card attribute" do
    it "gets email attribute" do
      @account_card.role.should == 'request'
    end

    it "shouldn't have a reader method for card_writer" do
      @account_card.respond_to?( :write).should be_false
      @account_card.method( :write= ).should be
    end

    it "shouldn't have a reader method for card_reader" do
      @account_card.method( :read).should be
      @account_card.respond_to?( :read= ).should be_false
    end

    it "sets and saves attribute" do
      @account_card.write= 'test_value'
      @account_card.status= 'pending'
      @account_card.status.should == 'pending'
      Account.as_bot { @account_card.save }
      Card.cache.reset
      (tcard = Card['sara'].fetch(:trait=>:account)).should be
      tcard.status.should == 'pending'
      tcard.fetch(:trait=>:write).content.should == 'test_value'
    end
  end

  let(:card) { proxy Card.new(:name=>'simple') }
  let(:card_self) { proxy Card.new(:name=>'*navbox') }
  let(:card_right) { proxy Card.new(:name=>'card+*right') }
  let(:card_type_search) { proxy Card.new(:name=>'search_me', :type=>Card::SearchID) }
  let(:card_double) { proxy Card }
  let(:format_double) { proxy Card::Format }
  let(:html_format_double) { proxy Card::HtmlFormat }

  it "should define Formatter methods from modules" do
    format_double.method(:render_navbox_self_core).should be
    format_double.method(:_render_right_right_raw).should be
    format_double.method(:render_type_search_core).should be
    format_double.method(:_final_type_search_raw).should be
  end
  it "should call set render methods" do
    card_self.should_receive(:_final_self_navbox_core)
    card_self.render_core
    card_right.method(:_render_right_right_raw).should be
    card_right.render_core
    card_type_search.method(:render_type_search_core).should be
    card_type_search.render_core
    card.method(:_final_type_search_raw).should be
    card.render_core
  end
  it "should define Formatter methods from modules" do
    html_format_double.method(:render_self_navbox_core).should be
    html_format_double.method(:_render_right_right_raw).should be
    html_format_double.method(:render_type_search_core).should be
    html_format_double.method(:_final_type_search_raw).should be
  end
  it "should define Formatter methods from modules" do
    card_self.should_receive(:_final_self_navbox_titled)
    card_self.render_titled
    card_right.method(:_render_right_right_edit).should be
    card_right.render_edit
    card_type_search.method(:render_type_search_menu).should be
    card_type_search.render_menu
    card.method(:_final_type_search_content).should be
    card.render_content
  end
end
