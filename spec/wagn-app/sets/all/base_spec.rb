# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'
require File.expand_path('../../../packs/pack_spec_helper', File.dirname(__FILE__))

describe Wagn::Renderer do
  it "should render denial when user lacks read permissions" do
    c = Card.fetch('Administrator links')
    c.who_can(:read).should == [Card::AdminID]
    Account.as(:anonymous) do
      c.ok?(:read).should == false
      Wagn::Renderer.new(c).render(:core).match('denied').should_not be_nil
    end
  end
end


describe Wagn::Set::All::Base do
  it "should ignore underscores" do
    render_card(:not_found).should == render_card('not found')
  end
end

