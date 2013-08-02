# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'
#Card::Content

describe Card::Chunk::EscapedLiteral, "literal chunk tests" do
  include MySpecHelpers

  it "should test_escape_link" do
    card = newcard('link howto', 'write this: \[[text]]')
    render_test_card(card).should == 'write this: <span>[</span>[text]]'

  end

  it "should test_escape_inclusion" do
    card = newcard('inclusion howto', 'write this: \{{cardname}}')
    render_test_card(card).should == 'write this: <span>{</span>{cardname}}'
  end

end

