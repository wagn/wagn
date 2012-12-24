require File.expand_path('../../spec_helper', File.dirname(__FILE__))
include ChunkSpecHelper

describe Literal::Escape, "literal chunk tests" do

  before do
    setup_user 'joe_user'
  end

  it "should test_escape_link" do
    card = newcard('link howto', 'write this: \[[text]]')
    render_test_card(card).should == 'write this: <span>[</span>[text]]'

  end

  it "should test_escape_inclusion" do
    card = newcard('inclusion howto', 'write this: \{{cardname}}')
    render_test_card(card).should == 'write this: <span>{</span>{cardname}}'
  end

end

