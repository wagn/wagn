require File.expand_path('../../test_helper', File.dirname(__FILE__))

class LiteralTest < ActiveSupport::TestCase
  include ChunkSpecHelper


  def setup
    super
    setup_default_user
  end

  def test_escape_link
    card = newcard('link howto', 'write this: \[[text]]')
    assert_equal('write this: <span>[</span>[text]]', render_test_card(card) )

  end

  def test_escape_inclusion
    card = newcard('inclusion howto', 'write this: \{{cardname}}')
    assert_equal('write this: <span>{</span>{cardname}}', render_test_card(card) )
  end

end

