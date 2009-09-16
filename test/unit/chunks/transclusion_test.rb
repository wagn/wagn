require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

  include ActionView::Helpers::SanitizeHelper
#FIXME: None of these work now, since transclusion is handled at the slot/cache
# level, but these cases should still be covered by tests


class TransclusionTest < ActiveSupport::TestCase
  include ChunkTestHelper
  include ActionView::Helpers::TextHelper

  attr_accessor :controller

  def controller
    @controller ||= CardController.new()
  end

  def setup
    setup_default_user
  end

# For testing/console use of a slot w/o controllers etc.
  def self.full_sanitizer
    @full_sanitizer ||= HTML::FullSanitizer.new
  end

  def strip_all(c)
    cc = strip_tags(c)
    cc.gsub(/(<\!\[if !IE\]>|<\!\[endif\]>)+/,'')
  end

  def test_truth
    assert true
  end

  def slot_render(card, render_type=:content)
    slot = controller.help.new_slot(card,controller)
raise "No card" if card == nil
raise "Slot not created #{card.name}" if slot == nil
    ren = strip_all(slot.render(render_type))
ActionController::Base.logger.info("TEST:INFO:slot_render_testing #{card.name} R:#{ren}")
    ren
  end

 def test_circular_transclusion_should_be_invalid
    oak = Card.create! :name=>'Oak', :content=>'{{Foo}}'
    foo = Card.create! :name=>'Foo', :content=>'{{Quentin}}'
    qnt = Card.create! :name=>'Quentin', :content=>'{{Oak}}'
    #adm = Card.find_by_name('Wagn Bot')
    #adm.update_attributes :content => "{{Oak}}"
    assert_equal "{{Oak}}", strip_all(slot_render(qnt))
  end

  def test_missing_transclude
    a = Card.create :name=>'boo', :content=>"hey {{+there}}"
    #assert_text_equal "hey Click to create boo+there", slot_render(a)
    assert_equal "hey Add boo+there", strip_all(slot_render(a))
  end

  def test_absolute_transclude
    alpha = newcard 'Alpha', "Pooey"
    beta = newcard 'Beta', "{{Alpha}}"
    ren = strip_all(slot_render(beta))
    assert_text_equal "Pooey", ren
  end

  def test_template_transclusion
     age = newcard('age')
     t = newcard('*template')
     template = Card['*template']
     specialtype = Card::Cardtype.create :name=>'SpecialType'
     assert specialtype != nil
     assert template != nil
     
     specialtype_template = specialtype.connect template, "{{#{JOINT}age}}"
     assert_equal "Add SpecialType#{JOINT}*template#{JOINT}age", strip_all(slot_render(specialtype_template))
     wooga = Card::SpecialType.create :name=>'Wooga'
     # card = card('Wooga')  #wtf?
     wooga_age = wooga.connect( age, "39" )
     assert_equal  span(wooga_age, "39"), strip_all(slot_render(wooga))
     assert_equal ['Wooga'], wooga_age.transcluders.plot(:name)
   end

  def test_relative_transclude
    alpha = newcard 'Alpha', "{{#{JOINT}Beta}}"
    beta = newcard 'Beta'
    alpha_beta = alpha.connect beta, "Woot"
    assert_text_equal "Woot", strip_all(slot_render(alpha))
  end


  def test_shade_option
    alpha = newcard 'Alpha', "Pooey"
    beta = newcard 'Beta', "{{Alpha|shade:off}}"
    assert_text_equal "Pooey", strip_all(slot_render(newcard('Bee', "{{Alpha|shade:off}}" )))
    assert_text_equal "Pooey", strip_all(slot_render(newcard('Cee', "{{Alpha| shade: off }}" )))
    assert_text_equal "Pooey", strip_all(slot_render(newcard('Dee', "{{Alpha| shade:off }}" )))
    assert_text_equal "Pooey", strip_all(slot_render(newcard('Eee', "{{Alpha| shade:on }}" )))
  end


  # this tests container templating and transclusion syntax 'base:parent'
  def test_container_transclusion
    bob_city = Card.create! :name=>'bob+city', :content=> "Sparta"
    address_tmpl = Card.create! :name=>'address+*template', :content =>"{{+city|base:parent}}"
    bob_address = Card.create! :name=>'bob+address'
    #FIXME -- does not work retroactively if template is created later.

    #assert_equal span(bob_city, "Sparta"), slot_render(bob_address.reload), "include"
    assert_equal ["bob#{JOINT}address"], bob_city.transcluders.plot(:name)
  end

  def test_nested_transclude
    beta = newcard 'Beta', "{{Delta}}"
    assert beta != nil
    delta = newcard 'Delta', "Booya"
    assert delta != nil
    alpha = newcard 'Alpha', "{{Beta}}"
    assert alpha != nil
    assert_text_equal "Booya", strip_all(slot_render(alpha))
  end


  private
  def assert_text_equal(left, right, desc="")
    assert_equal strip_tags(left), strip_tags(right), desc
  end

  def span(card, text)
    %{<span class="transcluded editOnDoubleClick" cardId="#{card.id}" inPopup="true">} +
      %{<span class="content transcludedContent" cardId="#{card.id}">#{text}</span></span>}
  end

end
