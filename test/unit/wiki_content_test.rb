require File.expand_path('../test_helper', File.dirname(__FILE__))

class WikiContentTest < ActiveSupport::TestCase

#  def test_clean_tables
#    assert_equal '     foo     ', WikiContent.clean_html!("<table> <tbody><tr><td>foo</td></tr> </tbody></table>")
#  end

  def test_clean
    assert_equal ' [grrew][/wiki/grrew]ss ',WikiContent.clean_html!(' [grrew][/wiki/grrew]ss ')
    assert_equal '<p>html<div>with</div> funky tags</p>', WikiContent.clean_html!('<p>html<div class="boo">with</div><monkey>funky</butts>tags</p>')
  end

  def test_clean_should_allow_permitted_classes
    assert_equal '<span class="w-spotlight">foo</span>', WikiContent.clean_html!('<span class="w-spotlight">foo</span>')
    assert_equal '<p class="w-highlight">foo</p>', WikiContent.clean_html!('<p class="w-highlight">foo</p>')
  end

  def test_clean_should_disallow_nonpermitted_classes_in_spans
    assert_equal '<span>foo</span>', WikiContent.clean_html!('<span class="banana">foo</span>')
  end

  def test_clean_should_allow_permitted_attributes
    assert_equal '<img src="foo">',   WikiContent.clean_html!('<img src="foo">')
    assert_equal '<img alt="foo">',   WikiContent.clean_html!('<img alt="foo">')
    assert_equal '<img title="foo">', WikiContent.clean_html!('<img title="foo">')
    assert_equal '<a href="foo">',    WikiContent.clean_html!('<a href="foo">')
    assert_equal '<code lang="foo">', WikiContent.clean_html!('<code lang="foo">')
    assert_equal '<blockquote cite="foo">', WikiContent.clean_html!('<blockquote cite="foo">')
  end

  def test_clean_should_not_allow_nonpermitted_attributes
    assert_equal '<img>',   WikiContent.clean_html!('<img size="25">')
    assert_equal '<p>',   WikiContent.clean_html!('<p font="blah">')
  end

  def test_clean_should_remove_comments
    assert_equal 'yo', WikiContent.clean_html!('<!-- not me -->yo')
    assert_equal 'joe', WikiContent.clean_html!('<!-- not me -->joe<!-- not me -->')
  end
end
