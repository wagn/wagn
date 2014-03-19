# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card::Set::All::Name do
  describe 'autoname' do
    before do
      Card::Auth.as_bot do
        @b1 = Card.create! :name=>'Book+*type+*autoname', :content=>'b1'
      end
    end

    it "should handle cards without names" do
      c = Card.create! :type=>'Book'
      c.name.should== 'b1'
    end

    it "should increment again if name already exists" do
      b1 = Card.create! :type=>'Book'
      b2 = Card.create! :type=>'Book'
      b2.name.should== 'b2'
    end

    it "should handle trashed names" do
      b1 = Card.create! :type=>'Book'
      Card::Auth.as_bot { b1.delete }
      b1 = Card.create! :type=>'Book'
      b1.name.should== 'b1'
    end
  end
end
