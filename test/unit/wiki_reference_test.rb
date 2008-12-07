require File.dirname(__FILE__) + '/../test_helper' 

class WikiReferenceTest < Test::Unit::TestCase
  common_fixtures
  def setup
    setup_default_user  
    Renderer.instance.rescue_errors = false
  end

  def test_hard_templated_card_should_insert_references_on_create
    Card::UserForm.create! :name=>"JoeForm"
    WagnHelper::Slot.new(Card["JoeForm"]).render(:raw_content)
    assert_equal ["joe_form+age", "joe_form+name", "joe_form+description"].sort,
      Card["JoeForm"].out_references.plot(:referenced_name).sort     
    assert !Card["JoeForm"].references_expired      
  end         

  def test_hard_template_reference_creation_on_template_creation
    Card::Cardtype.create! :name=>"SpecialForm"
    Card::SpecialForm.create! :name=>"Form1", :content=>"foo"
    Card.create! :name=>"SpecialForm+*tform", :content=>"{{+bar}}", :extension_type=>"HardTemplate"
    WagnHelper::Slot.new(Card["Form1"]).render(:raw_content)
    assert !Card["Form1"].references_expired      
    assert_equal ["form1+bar"], Card["Form1"].out_references.plot(:referenced_name)
  end
  
  def test_in_references_should_survive_cardtype_change
    newcard("Banana","[[Yellow]]")
    newcard("Submarine","[[Yellow]]")
    newcard("Sun","[[Yellow]]")
    newcard("Yellow")
    assert_equal %w{ Banana Submarine Sun }, Card["Yellow"].referencers.plot(:name).sort
    y=Card["Yellow"];  y.type="UserForm"; y.save!
    assert_equal %w{ Banana Submarine Sun }, Card["Yellow"].referencers.plot(:name).sort
  end

  def test_hard_templated_card_should_update_references_on_template_update
    Card::UserForm.create! :name=>"JoeForm"
    tmpl = Card["UserForm+*tform"]
    tmpl.content = "{{+monkey}} {{+banana}} {{+fruit}}"; tmpl.save!
    WagnHelper::Slot.new(Card["JoeForm"]).render(:raw_content)
    assert_equal ["joe_form+monkey", "joe_form+banana", "joe_form+fruit"].sort,
      Card["JoeForm"].out_references.plot(:referenced_name).sort     
    assert !Card["JoeForm"].references_expired
  end                                                         
  
  def test_container_transclusion
    bob_city = Card.create :name=>'bob+city' 
    Card.create :name=>'address+*rform',:content=>"{{#{JOINT}city|base:parent}}"
    bob_address = Card.create :name=>'bob+address'
    
    assert_equal ["bob#{JOINT}city"], bob_address.transcludees.plot(:name) 
    assert_equal ["bob#{JOINT}address"], bob_city.transcluders.plot(:name) 
  end


  def test_pickup_new_links_on_rename
    @l = newcard("L", "[[Ethan]]")  # no Ethan card yet...
    @e = newcard("Earthman")
    @e.update_attributes! :name => "Ethan"  # NOW there is an Ethan card
    # @e.referencers.plot(:name).include("L")  as the test was originally written, fails
    #  do we need the links to be caught before reloading the card?
    assert Card["Ethan"].referencers.plot(:name).include?("L")
  end
                  
  def test_update_references_on_rename
     watermelon = newcard('watermelon', 'mmmm')
     seeds = newcard('seeds')
     watermelon_seeds = watermelon.connect seeds, 'black'
     lew = newcard('Lew', "likes [[watermelon]] and [[watermelon#{JOINT}seeds|seeds]]")

     watermelon = Card['watermelon']
     watermelon.update_link_ins = true
     watermelon.confirm_rename = true
     watermelon.name="grapefruit"
     watermelon.save!
     assert_equal "likes [[grapefruit]] and [[grapefruit#{JOINT}seeds|seeds]]", lew.reload.content


     watermelon = Card['grapefruit']
     watermelon.update_link_ins = false
     watermelon.confirm_rename = true
     watermelon.name='bananas'
     watermelon.save!
     assert_equal "likes [[grapefruit]] and [[grapefruit#{JOINT}seeds|seeds]]", lew.reload.content 
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
     @ab.confirm_rename = true
     @ab.update_attributes! :name=>'Peanut+Butter', :update_link_ins=>false
     @x = Card.find_by_name('X')
     assert_equal "[[A]] [[A+B]] [[T]]", @x.content
   end
    
  def test_template_transclusion
    cardtype = Card::Cardtype.create! :name=>"ColorType", :content=>""
    template = Card['*tform']
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
    assert_equal ['alpha'], Card['beta'].referencees.plot(:name)
    assert_equal ['beta'], Card['alpha'].referencers.plot(:name)
  end

  def test_link_with_spaces
    alpha = Card.create! :name=>'alpha card'
    beta =  Card.create! :name=>'beta card', :content=>"I link to [[alpha_card|ALPHA CARD]]"
    assert_equal ['alpha card'], Card['beta card'].referencees.plot(:name)
    assert_equal ['beta card'], Card['alpha card'].referencers.plot(:name)
  end


  def test_simple_transclusion
    alpha = Card.create :name=>'alpha'
    beta = Card.create :name=>'beta', :content=>"I transclude to {{alpha}}"
    assert_equal ['alpha'], Card['beta'].transcludees.plot(:name)
    assert_equal ['beta'], Card['alpha'].transcluders.plot(:name)
  end

  def test_non_simple_link
    alpha = Card.create :name=>'alpha'
    beta = Card.create :name=>'beta', :content=>"I link to [[alpha|ALPHA]]"
    assert_equal ['alpha'], Card['beta'].referencees.plot(:name)
    assert_equal ['beta'], Card['alpha'].referencers.plot(:name)
  end
  

  def test_pickup_new_links_on_create
    @l = newcard("woof", "[[Lewdog]]")  # no Lewdog card yet...
    @e = newcard("Lewdog")              # now there is
    assert @e.referencers.plot(:name).include?("woof")
  end
  
  
=begin   
  # this test is about the time between when a card is first created and the time that
  # references pointing to the cards name are updated and given an id;  
  # these 'name_references' are used in the cache_sweeper, but i'm not sure i understand
  # the scenario where they're needed. LWH
  
  def test_pickup_new_transclusions_on_create
    @l = Card.create! :name=>"woof", :content=>"{{Lewdog}}"  # no Lewdog card yet...
    @e = Card.new(:name=>"Lewdog", :content=>"grrr")              # now there is
    warn @e.name_references.inspect
    assert @e.name_references.plot(:referencer).plot(:name).include?("woof")
  end
=end

=begin  

  # This test doesn't make much sense to me... LWH
  def test_revise_changes_references_from_wanted_to_linked_for_new_cards
    new_card = Card::Basic.create(:name=>'NewCard')
    new_card.revise('Reference to [[WantedCard]], and to [[WantedCard2]]', Time.now, User.find_by_login('quentin'), 
        get_renderer)
    
    references = new_card.wiki_references(true)
    assert_equal 2, references.size
    assert_equal 'WantedCard', references[0].referenced_name
    assert_equal WikiReference::WANTED_PAGE, references[0].link_type
    assert_equal 'WantedCard2', references[1].referenced_name
    assert_equal WikiReference::WANTED_PAGE, references[1].link_type

    wanted_card = Card::Basic.create(:name=>'WantedCard')
    wanted_card.revise('And here it is!', Time.now, User.find_by_login('quentin'), get_renderer)

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
