require File.expand_path('../../spec_helper', File.dirname(__FILE__))
include ChunkSpecHelper

describe Literal::Escape, "literal chunk tests" do

  before do
    setup_user 'joe_user'
  end

  it "should test_escape_link" do
    card = newcard('link howto', 'write this: \[[text]]')
    assert_equal('write this: <span>[</span>[text]]', render_test_card(card) )

  end

  it "should test_escape_inclusion" do
    card = newcard('inclusion howto', 'write this: \{{cardname}}')
    assert_equal('write this: <span>{</span>{cardname}}', render_test_card(card) )
  end

end

