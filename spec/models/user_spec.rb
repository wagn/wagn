# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe "User" do
  describe "#read_rules" do
    before(:all) do
      @read_rules = Card['joe_user'].read_rules
    end


    it "*all+*read should apply to Joe User" do
      @read_rules.member?(Card.fetch('*all+*read').id).should be_true
    end

    it "3 more should apply to Joe Admin" do
      Account.as(:joe_admin) do
        ids = Account.as_card.read_rules
        #warn "rules = #{ids.map(&Card.method(:find)).map(&:name) * ', '}"
        ids.length.should == @read_rules.size+3
      end
    end

  end
end
