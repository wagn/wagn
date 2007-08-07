require File.dirname(__FILE__) + '/../test_helper'
class WikiReferenceTest < Test::Unit::TestCase
  common_fixtures
  def setup
    setup_default_user  
    Renderer.instance.rescue_errors = false
  end


  def test_container_transclusion
    bob_city = Card.create :name=>'bob+city' 
    Card.create :name=>'address+*template',:content=>"{{#{JOINT}city|base:parent}}"
    bob_address = Card.create :name=>'bob+address'
    
    assert_equal ["bob#{JOINT}city"], bob_address.transcludees.plot(:name) 
    assert_equal ["bob#{JOINT}address"], bob_city.transcluders.plot(:name) 
  end

  def test_pickup_new_links_on_rename
    @l = newcard("L", "[[Ethan]]")  # no Ethan card yet...
    @e = newcard("Earthman")
    @e.update_attributes! :name => "Ethan"  # NOW there is an Ethan card
    assert @e.referencers.plot(:name).include?("L")
  end

  def test_update_references_on_rename
     watermelon = newcard('watermelon', 'mmmm')
     seeds = newcard('seeds')
     watermelon_seeds = watermelon.connect seeds, 'black'
     lew = newcard('Lew', "likes [[watermelon]] and [seeds][watermelon#{JOINT}seeds]")

     watermelon.on_rename_skip_reference_updates=false
     watermelon.name="grapefruit"
     watermelon.save
     assert_equal "likes [[grapefruit]] and [seeds][grapefruit#{JOINT}seeds]", lew.reload.content

     watermelon.on_rename_skip_reference_updates=true
     watermelon.name='bananas'
     watermelon.save
     assert_equal "likes [[grapefruit]] and [seeds][grapefruit#{JOINT}seeds]", lew.reload.content 
     w = ReferenceTypes::WANTED_LINK
     assert_equal [w,w], lew.out_references.plot(:link_type), "links should be Wanted"
   end

   def test_update_referencing_content_on_rename_junction_card
     @ab = Card.find_by_name("A+B") #linked to from X, transcluded by Y
     @ab.update_attributes! :name=>'Peanut+Butter'
     @x = Card.find_by_name('X')
     assert_equal "[[A]] [[Peanut+Butter]] [[T]]", @x.content
   end

   def test_update_referencing_content_on_rename_junction_card
     @ab = Card.find_by_name("A+B") #linked to from X, transcluded by Y
     @ab.update_attributes! :name=>'Peanut+Butter', :on_rename_skip_reference_updates=>true
     @x = Card.find_by_name('X')
     assert_equal "[[A]] [[A+B]] [[T]]", @x.content
   end
    
  def test_template_transclusion
    cardtype = Card::Cardtype.create! :name=>"ColorType", :content=>""
    template = Card.create! :name=>'*template'
    Card.create! :trunk=>cardtype, :tag=>template, :content=>"{{#{JOINT}rgb}}"
    blue = Card::ColorType.create! :name=>"blue"
    rgb = newcard 'rgb'
    blue_rgb = Card.create! :trunk=>blue, :tag=>rgb, :content=>"#OOOOFF"
    
    assert_equal ["blue#{JOINT}rgb"], blue.reload.transcludees.plot(:name)
    assert_equal ['blue'], blue_rgb.reload.transcluders.plot(:name)
  end

  def test_simple_link
    alpha = Card.create :name=>'alpha'
    beta = Card.create :name=>'beta', :content=>"I link to [[alpha]]"
    assert_equal ['alpha'], beta.referencees.plot(:name)
    assert_equal ['beta'], alpha.referencers.plot(:name)
  end


  def test_simple_transclusion
    alpha = Card.create :name=>'alpha'
    beta = Card.create :name=>'beta', :content=>"I transclude to {{alpha}}"
    assert_equal ['alpha'], beta.transcludees.plot(:name)
    assert_equal ['beta'], alpha.transcluders.plot(:name)
  end

  def test_non_simple_link
    alpha = Card.create :name=>'alpha'
    beta = Card.create :name=>'beta', :content=>"I link to [ALPHA][alpha]"
    assert_equal ['alpha'], beta.referencees.plot(:name)
    assert_equal ['beta'], alpha.referencers.plot(:name)
  end
  
  def test_link_with_spaces
    alpha = Card.create :name=>'alpha card'
    beta =  Card.create :name=>'beta card', :content=>"I link to [ALPHA CARD][alpha_card]"
    assert_equal ['alpha card'], beta.referencees.plot(:name)
    assert_equal ['beta card'], alpha.referencers.plot(:name)
  end

  def test_pickup_new_links_on_create
    @l = newcard("woof", "[[Lewdog]]")  # no Lewdog card yet...
    @e = newcard("Lewdog")              # now there is
    assert @e.referencers.plot(:name).include?("woof")
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
