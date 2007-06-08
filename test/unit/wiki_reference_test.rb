require File.dirname(__FILE__) + '/../test_helper'
class WikiReferenceTest < Test::Unit::TestCase
  common_fixtures
  def setup
    setup_default_user
  end

  def test_container_transclusion
    bob,city = newcard('bob'), newcard('city')
    bob_city = bob.connect city, "sparta" 
    address = newcard 'address', "Don't see me"
    tmpl = newcard('*template')
    address.connect(tmpl, "{{#{JOINT}city|base:parent}}")
    bob_address = bob.connect address
    
    assert_equal ["bob#{JOINT}city"], bob_address.transcludees.plot(:name) 
    assert_equal ["bob#{JOINT}address"], bob_city.transcluders.plot(:name) 
  end

  def test_simple_transclusion
    alpha = newcard('alpha')
    beta = newcard('beta', "I transclude to {{alpha}}")
    assert_equal ['alpha'], beta.transcludees.plot(:name)
    assert_equal ['beta'], alpha.transcluders.plot(:name)
  end

  def test_template_transclusion
    cardtype = Card::Cardtype.create :name=>"Color", :content=>""
    template = newcard '*template'
    cardtype.connect template, "{{#{JOINT}rgb}}"
    blue = Card::Color.create :name=>"blue"
    rgb = newcard 'rgb'
    blue_rgb = blue.connect rgb, "#OOOOFF"
    
    assert_equal ["blue#{JOINT}rgb"], blue.reload.transcludees.plot(:name)
    assert_equal ['blue'], blue_rgb.reload.transcluders.plot(:name)
  end

  def test_simple_link
    alpha = newcard('alpha')
    beta = newcard('beta', "I link to [[alpha]]")
    assert_equal ['alpha'], beta.referencees.plot(:name)
    assert_equal ['beta'], alpha.referencers.plot(:name)
  end

  def test_non_simple_link
    alpha = newcard('alpha')
    beta = newcard('beta', "I link to [ALPHA][alpha]")
    assert_equal ['alpha'], beta.referencees.plot(:name)
    assert_equal ['beta'], alpha.referencers.plot(:name)
  end
  
  def test_link_with_spaces
    alpha = newcard('alpha card')
    beta = newcard('beta card', "I link to [ALPHA CARD][alpha_card]")
    assert_equal ['alpha card'], beta.referencees.plot(:name)
    assert_equal ['beta card'], alpha.referencers.plot(:name)
  end
  
=begin  
  def test_revise_changes_references_from_wanted_to_linked_for_new_cards
    new_card = Card::Basic.create(:name=>'NewCard')
    new_card.revise('Reference to [[WantedCard]], and to [[WantedCard2]]', Time.now, User.find_by_login('quentin'), 
        test_renderer)
    
    references = new_card.wiki_references(true)
    assert_equal 2, references.size
    assert_equal 'WantedCard', references[0].referenced_name
    assert_equal WikiReference::WANTED_PAGE, references[0].link_type
    assert_equal 'WantedCard2', references[1].referenced_name
    assert_equal WikiReference::WANTED_PAGE, references[1].link_type

    wanted_card = Card::Basic.create(:name=>'WantedCard')
    wanted_card.revise('And here it is!', Time.now, User.find_by_login('quentin'), test_renderer)

    # link type stored for NewCard -> WantedCard reference should change from WANTED to LINKED
    # reference NewCard -> WantedCard2 should remain the same
    references = new_card.wiki_references(true)
    assert_equal 2, references.size
    assert_equal 'WantedCard', references[0].referenced_name
    assert_equal WikiReference::LINKED_PAGE, references[0].link_type
    assert_equal 'WantedCard2', references[1].referenced_name
    assert_equal WikiReference::WANTED_PAGE, references[1].link_type
  end
=end


end
