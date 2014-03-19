# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card::Set::Rstar::Rules do
  it "should render setting view for a right set" do
     r = Card::Format.new(Card['*read+*right']).render_open
     r.should_not match(/error/i)
     r.should_not match('No Card!')
     #warn "r = #{r}"
     assert_view_select r, 'table[class="set-rules"]' do
       assert_select 'a[href~="/*read+*right+*input?view=open_rule"]', :text => 'input'
     end
  end

  it "should render setting view for a *input rule" do
    Card::Auth.as_bot do
      r = Card::Format.new(Card.fetch('*read+*right+*input',:new=>{})).render_open_rule
      r.should_not match(/error/i)
      r.should_not match('No Card!')
      #warn "r = #{r}"
      assert_view_select r, 'tr[class="card-slot open-rule edit-rule"]' do
        assert_select 'input[id="success_id"][name=?][type="hidden"][value="*read+*right+*input"]', 'success[id]'
      end
    end
  end
end
