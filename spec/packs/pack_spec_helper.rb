module PackSpecHelper

include ActionDispatch::Assertions::SelectorAssertions
#~~~~~~~~~  HELPER METHODS ~~~~~~~~~~~~~~~#

  
  def assert_view_select(view_html, *args, &block)
    node = HTML::Document.new(view_html).root
    if block_given?
      assert_select node, *args, &block
    else
      assert_select node, *args
    end
  end

  def render_editor(type)
    card = Card.create(:name=>"my favority #{type} + #{rand(4)}", :type=>type)
    Wagn::Renderer.new(card).render(:edit)
  end

  def render_content(content, args={})
    @card ||= Card.new :name=>"Tempo Rary 2"
    @card.content=content
    r = Wagn::Renderer.new @card,args
    #r.add_name_context "Tempo Rary 2"
    #warn "rc core #{r}"
    r._render(:core)
  end

  def xml_render_content(content, args={})
    args[:format] = :xml
    render_content(content, args)
  end

  def xml_render_card(view, card_args={})
    render_card(view, card_args, :format=>:xml)
  end

  def render_card(view, card_args={}, args={})
    card = begin
      if card_args[:name]
        Card.fetch(card_args[:name])
      else
        card_args[:name] ||= "Tempo Rary"
        c = Card.new(card_args)
      end
    end
    Wagn::Renderer.new(card, args)._render(view)
  end
end

RSpec::Core::ExampleGroup.send :include, PackSpecHelper
#ActiveSupport::TestCase.extend PackSpecHelper
