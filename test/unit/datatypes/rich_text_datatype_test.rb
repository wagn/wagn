require File.dirname(__FILE__) + '/../../test_helper'

class RichTextDatatypeTest < Test::Unit::TestCase
  
  def setup
    @tag = Tag.new( :name=>'datatype_tester',:datatype_key=>"RichText" )
    @card = Card::Basic.new( :tag=>@tag )
    @datatype = @tag.datatype   
    setup_default_user
  end
  
  # Replace this with your real tests.
  def test_table_of_contents
    a, a_toc = create_cards(['a', 'a+*table of contents'])
    a.content = "<h1>foo</h1>"
    assert_no_match /Table of Contents/, render(a)
    a_toc.content = "on"
    assert_match /Table of Contents/, render(a)
    a.content = "<h1>foo</h1><h1>bar</h1><h1>baz</h1><h1>faz</h1>"
    a_toc.content = "auto blah blah blah"
    assert_match /Table of Contents/, render(a)
    a_toc.content = "off"
    assert_no_match /Table of Contents/, render(a)
  end                                          
  
  
  
end
