require File.dirname(__FILE__) + '/../test_helper'
class CardnameTest < Test::Unit::TestCase
  def setup
  end
    
  def test_valid
    assert "this+THAT".valid_cardname?
#    assert !"Tho_se".valid_cardname?
    assert !"Tes~sd".valid_cardname?
    assert !"TEST/DDER".valid_cardname?
    assert "THE*ONE*AND$!ONLY".valid_cardname?
  end       
  
  def test_parent_name
    assert_equal "a+b+c", "a+b+c+d".parent_name
    assert_equal nil, "a".parent_name
  end
  
  def test_tag_name
    assert_equal "c", "a+b+c".tag_name
    assert_equal "a", "a".tag_name
  end
  
end
    
