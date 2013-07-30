# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'
module Wagn::PatternSpecHelper
  def it_generates( opts )
    name = opts[:name]
    card = opts[:from]
    it "generates name '#{name}' for card '#{card.name}'" do
      described_class.new(card).to_s.should == name
    end
  end
end

RSpec::Core::ExampleGroup.extend Wagn::PatternSpecHelper
