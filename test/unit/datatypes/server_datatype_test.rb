require File.dirname(__FILE__) + '/../../test_helper'

class ServerDatatypeTest < Test::Unit::TestCase
  def setup
    @tag = Tag.new( :name=>'datatype_tester',:datatype_key=>"Server" )
    @card = Card::Basic.new( :tag=>@tag )
    @datatype = @tag.datatype
  end
  
  # Replace this with your real tests.
  def test_render
    #assert_equal "foo", @card.content_for_rendering
  end
end
