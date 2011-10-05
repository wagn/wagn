require File.expand_path('../../test_helper', File.dirname(__FILE__))

class LiteralTest < ActiveSupport::TestCase
  include ChunkTestHelper
  
  
  def setup
    super
    setup_default_user
  end
  
=begin
  def test_literal_link
    card = newcard('Instructions', '/* type this: [[link]] */')
    assert_equal('<code> type this: [[link]] </code>', render(card) )
  
    card2 = newcard('Double lit', '/*in*/ out /*in*/')
    assert_equal('<code>in</code> out <code>in</code>', render(card2) )
  end
=end
  
  def test_escape_link
    card = newcard('link howto', 'write this: \[[text]]')
    assert_equal('write this: <span>[</span>[text]]', render_test_card(card) )

  end
  
  def test_escape_inclusion
    card = newcard('inclusion howto', 'write this: \{{cardname}}')
    assert_equal('write this: <span>{</span>{cardname}}', render_test_card(card) )
  end
  
end                                                                      
  
