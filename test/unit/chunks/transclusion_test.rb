require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class TransclusionTest < Test::Unit::TestCase
  test_helper :chunk
  common_fixtures
  def setup
    setup_default_user
  end     
  
  def test_shade_option
    alpha = newcard 'Alpha', "Pooey"
    beta = newcard 'Beta', "{{Alpha|shade:off}}"
    assert_equal "Pooey", render(newcard('B', "{{Alpha|shade:off}}" ))
    assert_equal "Pooey", render(newcard('C', "{{Alpha| shade: off }}" ))
    assert_equal "Pooey", render(newcard('D', "{{Alpha| shade:off }}" ))
    assert_equal span(alpha,"Pooey"), render(newcard('E', "{{Alpha| shade:on }}" ))
  end
                                                                         
  def test_relative_transclude                                         
    alpha = newcard 'Alpha', "{{#{JOINT}Beta}}"
    beta = newcard 'Beta'
    alpha_beta = alpha.add_tag( beta.tag, "Woot" )
    assert_equal span(alpha_beta, "Woot"), render(alpha)
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
    bob,city = newcard('Bob'), newcard('city')
    bob_city = bob.connect( city, "Sparta" )

    address = newcard 'address', "Shouldn't see this"
    tmpl = newcard('*template')
    address.connect(tmpl, "{{#{JOINT}city|base:parent}}")
    #address.tag.update_attribute :plus_template, true
    bob_address = bob.connect( address, "daa" )

    assert_equal span(bob_city, "Sparta"), render(bob_address), "include" 
    assert_equal ["Bob#{JOINT}address"], bob_city.transcluders.plot(:name)
  end

  def test_circular_transclusion  
    newcard 'Oak', "oak"
    newcard 'Quentin', "quentin"
    
    Card.find_by_name('Admin').content = "{{Oak}}"
    Card.find_by_name('Oak').content = "{{Quentin}}"
    
    Card.find_by_name('Quentin').content = "{{Admin}}"
    assert_match /Error .* Circular transclusion/, render(Card.find_by_name('Quentin')) 
   
    Card.find_by_name('Oak').content = "{{Admin}}"
    
    #warn "\n\n--------------cards updated ----------------\n\n"
    assert card_content('Quentin')
  end
  
  def test_template_transclusion
    age, template = newcard('age'), newcard('*template')
    specialtype = Card::Cardtype.create :name=>'SpecialType'
    
    specialtype_template = specialtype.add_tag( template.tag, "{{#{JOINT}age}}" )
    assert_equal "{{#{JOINT}age}}", test_renderer.render(specialtype_template)
    wooga = Card::SpecialType.create :name=>'Wooga'
    card = card('Wooga')
    wooga_age = wooga.connect( age, "39" )
    assert_equal  span(wooga_age, "39"), test_renderer.render(wooga)
    assert_equal ['Wooga'], wooga_age.transcluders.plot(:name)
  end
   
  def test_nested_transclude
    alpha = newcard 'Alpha', "{{Beta}}"
    beta = newcard 'Beta', "{{Delta}}"
    delta = newcard 'Delta', "Booya"
    assert_equal span(beta, span(delta, "Booya" )), render( alpha )
  end                                                                  
                                                                         
  def test_absolute_transclude
    alpha = newcard 'Alpha', "Pooey"
    beta = newcard 'Beta', "{{Alpha}}"
    assert_equal span(alpha, "Pooey"), render(beta)
  end                                                                  
                                                                       
  private  
  
  def span(card, text)
    %{<span class="transcluded editOnDoubleClick" cardId="#{card.id}" inPopup="true">} +
      %{<span class="transcludedContent" cardId="#{card.id}">#{text}</span></span>}
  end

end
