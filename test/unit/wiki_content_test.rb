require File.dirname(__FILE__) + '/../test_helper'

class WikiContentTest < Test::Unit::TestCase
  
  def test_clean_tables
    assert_equal '     foo     ', WikiContent.clean_html!("<table> <tbody><tr><td>foo</td></tr> </tbody></table>")
  end
  
  def test_clean
    assert_equal ' [grrew][/wiki/grrew]ss ',WikiContent.clean_html!(' [grrew][/wiki/grrew]ss ')
    assert_equal '<p>html with  funky tags</p>', WikiContent.clean_html!('<p>html<div class="boo">with</div><table>funky</td>tags</p>')
  end

  def test_clean_should_allow_permitted_classes_in_spans
    assert_equal '<span class="w-spotlight">foo</span>', WikiContent.clean_html!('<span class="w-spotlight">foo</span>')
    assert_equal '<span class="w-highlight">foo</span>', WikiContent.clean_html!('<span class="w-highlight">foo</span>')
  end
  
  def test_clean_should_disallow_nonpermitted_classes_in_spans
    assert_equal '<span>foo</span>', WikiContent.clean_html!('<span class="banana">foo</span>')
  end
  
  def test_links
    assert_equal '[[ethan]]', WikiContent.process_links!('<a href="ethan">ethan</a>')
    assert_equal '[[ethan]] and [lewis][Lew]', WikiContent.process_links!('<a href="ethan">ethan</a> and <a href="Lew">lewis</a>')
    assert_equal '[[ethan]]', WikiContent.process_links!('<a href="http://brahma:3033/wagn/ethan">ethan</a>', url_root='http://brahma:3033')
    assert_equal '[[ethan]]', WikiContent.process_links!('[[ethan]]')
  end
end
