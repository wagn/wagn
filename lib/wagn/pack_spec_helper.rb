# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'
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
