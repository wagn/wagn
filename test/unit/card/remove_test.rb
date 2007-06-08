require File.dirname(__FILE__) + '/../../test_helper'
class Card::RemoveTest < Test::Unit::TestCase
  common_fixtures

  def setup
    setup_default_user
    @z = newcard("Z", "I'm here to be referenced to")
    @a = newcard("A", "Alpha [[Z]]")
    @b = newcard("B", "Beta {{Z}}")        
    @t = newcard("T", "Theta")
    @ab = @a.connect(@b, "AlphaBeta")
    # references
    @x = newcard("X", "[[A]] [[A+B]] [[T]]")
    @y = newcard("Y", "{{B}} {{A+B}} {{A}} {{T}}")
  end


  def test_remove
    assert @a.referencers.plot(:name).include?("X")
    assert @a.destroy
  end

end

