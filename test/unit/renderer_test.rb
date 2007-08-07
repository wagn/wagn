require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require 'renderer'

class RendererTest < Test::Unit::TestCase
  test_helper :renderer
  common_fixtures
  
  def setup
    setup_default_user
    @template = Renderer::StubTemplate.new
    @renderer = Renderer.instance
  end

  def test_render_given_content
    @c = Card.find_by_name('revtest')
    assert_equal 'first', @renderer.render(@c,@c.revisions[0].content)
  end
  
  def test_link_changing
    apple = newcard('apple','foobar [[banana]]')
    old_content = @renderer.render(apple)
    assert_equal ['banana'], apple.out_references.plot(:referenced_name)
    content = @renderer.process(apple,nil,update_refs=true) do |wiki_content|
      wiki_content.find_chunks(Chunk::Link).each do |chunk|
        chunk.card_name.gsub!(/banana/,'orange')
      end
    end
    assert_equal 'foobar [[orange]]', content
    assert_equal ['orange'], apple.out_references(refresh=true).plot(:referenced_name)
  end
  
end
