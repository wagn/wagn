module PackSpecHelper
#~~~~~~~~~  HELPER METHODS ~~~~~~~~~~~~~~~#

  def render_editor(type)
    card = Card.create(:name=>"my favority #{type} + #{rand(4)}", :type=>type)
    Wagn::Renderer.new(card).render(:edit)
  end

  def render_content(content, args={})
    @card ||= Card.new(:name=>"Tempo Rary 2", :skip_defaults=>true)
    @card.content=content
    Wagn::Renderer.new(@card,args).render(:naked)
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
        card_args[:skip_defaults]=true
        c = Card.new(card_args)
      end
    end
    Wagn::Renderer.new(card, args).render(view)
  end
end

ActiveSupport::TestCase.send :include, PackSpecHelper
#ActiveSupport::TestCase.extend PackSpecHelper
