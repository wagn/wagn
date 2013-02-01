require File.expand_path('../test_helper', File.dirname(__FILE__))

class CleanHtmlTest < ActiveSupport::TestCase

#  def test_clean_tables
#    assert_equal '     foo     ', CleanHtml.clean!("<table> <tbody><tr><td>foo</td></tr> </tbody></table>")
#  end

  def test_clean
    assert_equal ' [grrew][/wiki/grrew]ss ',CleanHtml.clean!(' [grrew][/wiki/grrew]ss ')
    assert_equal '<p>html<div>with</div> funky tags</p>', CleanHtml.clean!('<p>html<div class="boo">with</div><monkey>funky</butts>tags</p>')
  end

  def test_clean_should_allow_permitted_classes
    assert_equal '<span class="w-spotlight">foo</span>', CleanHtml.clean!('<span class="w-spotlight">foo</span>')
    assert_equal '<p class="w-highlight">foo</p>', CleanHtml.clean!('<p class="w-highlight">foo</p>')
  end

  def test_clean_should_disallow_nonpermitted_classes_in_spans
    assert_equal '<span>foo</span>', CleanHtml.clean!('<span class="banana">foo</span>')
  end

  def test_clean_should_allow_permitted_attributes
    assert_equal '<img src="foo">',   CleanHtml.clean!('<img src="foo">')
    assert_equal '<img alt="foo">',   CleanHtml.clean!('<img alt="foo">')
    assert_equal '<img title="foo">', CleanHtml.clean!('<img title="foo">')
    assert_equal '<a href="foo">',    CleanHtml.clean!('<a href="foo">')
    assert_equal '<code lang="foo">', CleanHtml.clean!('<code lang="foo">')
    assert_equal '<blockquote cite="foo">', CleanHtml.clean!('<blockquote cite="foo">')
  end

  def test_clean_should_not_allow_nonpermitted_attributes
    assert_equal '<img>',   CleanHtml.clean!('<img size="25">')
    assert_equal '<p>',   CleanHtml.clean!('<p font="blah">')
  end

  def test_clean_should_remove_comments
    assert_equal 'yo', CleanHtml.clean!('<!-- not me -->yo')
    assert_equal 'joe', CleanHtml.clean!('<!-- not me -->joe<!-- not me -->')
  end
end
