require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class TransclusionTest < Test::Unit::TestCase
  test_helper :chunk
  common_fixtures
  def setup
    setup_default_user
  end
 
  def test_template_transclusion
     age, template = newcard('age'), newcard('*template')
     specialtype = Card::Cardtype.create :name=>'SpecialType'

     specialtype_template = specialtype.connect template, "{{#{JOINT}age}}" 
     assert_equal "{{#{JOINT}age}}", test_renderer.render(specialtype_template)
     wooga = Card::SpecialType.create :name=>'Wooga'
     # card = card('Wooga')  #wtf?
     wooga_age = wooga.connect( age, "39" )
     assert_equal  span(wooga_age, "39"), test_renderer.render(wooga)
     assert_equal ['Wooga'], wooga_age.transcluders.plot(:name)
   end

 
 
  def test_circular_transclusion_should_be_invalid
     oak = Card.create! :name=>'Oak', :content=>'{{Quentin}}'
     qnt = Card.create! :name=>'Quentin', :content=>'{{Admin}}'
     adm = Card.find_by_name('Admin')
     adm.update_attributes :content => "{{Oak}}"
     assert_match /Circular transclusion/, adm.errors.on(:content)
   end
 
       
  def test_relative_transclude                                         
    alpha = newcard 'Alpha', "{{#{JOINT}Beta}}"
    beta = newcard 'Beta'
    alpha_beta = alpha.connect beta, "Woot" 
    assert_equal span(alpha_beta, "Woot"), render(alpha)
  end           

  def test_absolute_transclude
    alpha = newcard 'Alpha', "Pooey"
    beta = newcard 'Beta', "{{Alpha}}"
    assert_equal span(alpha, "Pooey"), render(beta)
  end                                                                  

  
  def test_shade_option
    alpha = newcard 'Alpha', "Pooey"
    beta = newcard 'Beta', "{{Alpha|shade:off}}"
    assert_equal "Pooey", render(newcard('Bee', "{{Alpha|shade:off}}" ))
    assert_equal "Pooey", render(newcard('Cee', "{{Alpha| shade: off }}" ))
    assert_equal "Pooey", render(newcard('Dee', "{{Alpha| shade:off }}" ))
    assert_equal span(alpha,"Pooey"), render(newcard('Eee', "{{Alpha| shade:on }}" ))
  end
                                                                         
=begin  
  def test_nested_post_render
    a = newcard 'a', '3 + 4'
    a.tag.update_attribute :datatype_key, 'Ruby'
    b = newcard 'b', '{{a|shade:off}}'
    assert_equal '7', render(a), "ruby"
    assert_equal '7', render(b), "transcluded ruby -- HAS NEVER WORKED"
  end
=end
                          
  # this tests container templating and transclusion syntax 'base:parent'
  def test_container_transclusion
    bob_city = Card.create! :name=>'bob+city', :content=> "Sparta" 
    address_tmpl = Card.create! :name=>'address+*template', :content =>"{{+city|base:parent}}"
    bob_address = Card.create! :name=>'bob+address' 
    #FIXME -- does not work retroactively if template is created later.

    assert_equal span(bob_city, "Sparta"), render(bob_address.reload), "include" 
    assert_equal ["bob#{JOINT}address"], bob_city.transcluders.plot(:name)
  end

   
  def test_nested_transclude
    alpha = newcard 'Alpha', "{{Beta}}"
    beta = newcard 'Beta', "{{Delta}}"
    delta = newcard 'Delta', "Booya"
    assert_equal span(beta, span(delta, "Booya" )), render( alpha )
  end                                                                  
                                                                         
                                                                       
  private  
  
  def span(card, text)
    %{<span class="transcluded editOnDoubleClick" cardId="#{card.id}" inPopup="true">} +
      %{<span class="transcludedContent" cardId="#{card.id}">#{text}</span></span>}
  end

end
