require File.dirname(__FILE__) + '/../../test_helper'

class PlainTextDatatypeTest < Test::Unit::TestCase
  
  def setup
    @tag = Tag.new( :name=>'datatype_tester',:datatype_key=>"PlainText" )
    @card = Card::Basic.new( :tag=>@tag )
    @datatype = @tag.datatype
  end
  
  
  # Replace this with your real tests.
  def foo
  end
end
