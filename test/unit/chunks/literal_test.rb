require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class LiteralTest < Test::Unit::TestCase
  test_helper :chunk
  common_fixtures
  def setup
    setup_default_user
  end
  
  def test_literal_link
    card = newcard('Instructions', '/* type this: [[link]] */')
    assert_equal('<code> type this: [[link]] </code>', render(card) )

    card2 = newcard('Double lit', '/*in*/ out /*in*/')
    assert_equal('<code>in</code> out <code>in</code>', render(card2) )
  end
  
  def test_escape_link
    card = newcard('link howto', 'write this: \[[text]]')
    assert_equal('write this: <span>[</span>[text]]', render(card) )

  end
  
  def test_escape_inclusion
    card = newcard('inclusion howto', 'write this: \{{cardname}}')
    assert_equal('write this: <span>{</span>{cardname}}', render(card) )
  end
  
end                                                                      
  
