require File.expand_path('../../test_helper', File.dirname(__FILE__))

#FIXME: None of these work now, since transclusion is handled at the slot/cache
# level, but these cases should still be covered by tests


class TransclusionTest < ActiveSupport::TestCase
  include ChunkTestHelper
  include ActionView::Helpers::TextHelper

  def setup
    super
    setup_default_user
  end

  def test_truth
    assert true
  end

=begin


 def test_circular_transclusion_should_be_invalid
    oak = Card.create! :name=>'Oak', :content=>'{{Quentin}}'
    qnt = Card.create! :name=>'Quentin', :content=>'{{Admin}}'
    adm = Card['Wagn Bot']
    adm.update_attributes :content => "{{Oak}}"
    #warn "circles: " + render(adm)
    assert_match /Circular transclusion/, adm.errors[:content]
  end

  def test_missing_transclude
    @a = Card.create :name=>'boo', :content=>"hey {{+there}}"
    assert_text_equal "hey Click to create boo+there", render(@a)
  end

  def test_absolute_transclude
    alpha = newcard 'Alpha', "Pooey"
    beta = newcard 'Beta', "{{Alpha}}"
    assert_text_equal "Pooey", render(beta)
  end

  def test_template_transclusion
     age, template = newcard('age'), Card['*template']
     specialtype = Card.create :typecode=>'Cardtype', :name=>'SpecialType'

     specialtype_template = specialtype.connect template, "{{#{SmartName.joint}age}}"
     assert_equal "{{#{SmartName.joint}age}}", render_test_card(specialtype_template)
     wooga = Card::SpecialType.create :name=>'Wooga'
     # card = card('Wooga')  #wtf?
     wooga_age = wooga.connect( age, "39" )
     assert_text_equal  span(wooga_age, "39"), render_test_card(wooga)
     assert_text_equal ['Wooga'], wooga_age.transcluders.plot(:name)
   end

  def test_relative_transclude
    alpha = newcard 'Alpha', "{{#{SmartName.joint}Beta}}"
    beta = newcard 'Beta'
    alpha_beta = alpha.connect beta, "Woot"
    assert_text_equal "Woot", render(alpha)
  end


  def test_shade_option
    alpha = newcard 'Alpha', "Pooey"
    beta = newcard 'Beta', "{{Alpha|shade:off}}"
    assert_text_equal "Pooey", render(newcard('Bee', "{{Alpha|shade:off}}" ))
    assert_text_equal "Pooey", render(newcard('Cee', "{{Alpha| shade: off }}" ))
    assert_text_equal "Pooey", render(newcard('Dee', "{{Alpha| shade:off }}" ))
    assert_text_equal "Pooey", render(newcard('Eee', "{{Alpha| shade:on }}" ))
  end


  # this tests container templating and transclusion syntax 'base:parent'
  def test_container_transclusion
    bob_city = Card.create! :name=>'bob+city', :content=> "Sparta"
    address_tmpl = Card.create! :name=>'address+*template', :content =>"{{+city|base:parent}}"
    bob_address = Card.create! :name=>'bob+address'
    #FIXME -- does not work retroactively if template is created later.

    assert_text_equal span(bob_city, "Sparta"), render(bob_address.reload), "include"
    assert_equal ["bob#{SmartName.joint}address"], bob_city.transcluders.plot(:name)
  end


  def test_nested_transclude
    alpha = newcard 'Alpha', "{{Beta}}"
    beta = newcard 'Beta', "{{Delta}}"
    delta = newcard 'Delta', "Booya"
    assert_text_equal "Booya", render( alpha )
  end


  private
  def assert_text_equal(left, right, desc="")
    assert_equal strip_tags(left), strip_tags(right), desc
  end

  def span(card, text)
    %{<span class="transcluded" cardId="#{card.id}" inPopup="true">} +
      %{<span class="content transcludedContent" cardId="#{card.id}">#{text}</span></span>}
  end
=end

end
