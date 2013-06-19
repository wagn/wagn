# -*- encoding : utf-8 -*-
module Wagn::PackSpecHelper

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
    Card::Format.new(card).render(:edit)
  end

  def render_content(content, args={})
    @card ||= Card.new :name=>"Tempo Rary 2"
    @card.content=content
    r = Card::Format.new @card,args
    r._render(:core)
  end

  #FIXME -- shouldn't these just be in the xml test?
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
    Card::Format.new(card, args)._render(view)
  end
end

RSpec::Core::ExampleGroup.send :include, Wagn::PackSpecHelper
#ActiveSupport::TestCase.extend PackSpecHelper
