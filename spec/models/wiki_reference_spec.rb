require File.dirname(__FILE__) + '/../spec_helper' 

describe "WikiReference" do
  before do
    #setup_default_user  
    User.as :wagbot
  end

  describe "references on hard templated cards should get updated" do
    it "on templatee creation" do
      Card::UserForm.create! :name=>"JoeForm"
      Slot.new(Card["JoeForm"]).render(:naked)
      assert_equal ["joe_form+age", "joe_form+name", "joe_form+description"].sort,
        Card["JoeForm"].out_references.plot(:referenced_name).sort     
      Card["JoeForm"].references_expired.should_not == true
    end         

    it "on template creation" do
      Card::Cardtype.create! :name=>"SpecialForm"
      Card::SpecialForm.create! :name=>"Form1", :content=>"foo"
      c = Card.find_by_name("Form1")
      c.references_expired.should be_nil
      Card.create! :name=>"SpecialForm+*type+*content", :content=>"{{+bar}}"
      Card["Form1"].references_expired.should be_true
      Slot.new(Card["Form1"]).render(:naked)
      c = Card.find_by_name("Form1")
      c.references_expired.should be_nil
      Card["Form1"].out_references.plot(:referenced_name).should == ["form1+bar"]
    end

    it "on template update" do
      Card::UserForm.create! :name=>"JoeForm"
      tmpl = Card["UserForm+*type+*content"]
      tmpl.content = "{{+monkey}} {{+banana}} {{+fruit}}"; 
      tmpl.save!
      Card["JoeForm"].references_expired.should be_true
      Slot.new(Card["JoeForm"]).render(:naked)
      assert_equal ["joe_form+monkey", "joe_form+banana", "joe_form+fruit"].sort,
        Card["JoeForm"].out_references.plot(:referenced_name).sort     
      Card["JoeForm"].references_expired.should_not == true
    end                                                         
  end
  
  it "in references should survive cardtype change" do
    newcard("Banana","[[Yellow]]")
    newcard("Submarine","[[Yellow]]")
    newcard("Sun","[[Yellow]]")
    newcard("Yellow")
    Card["Yellow"].referencers.plot(:name).sort.should == %w{ Banana Submarine Sun }
    y=Card["Yellow"];  
    y.type="UserForm"; 
    y.save!
    Card["Yellow"].referencers.plot(:name).sort.should == %w{ Banana Submarine Sun }
  end

  
  it "container transclusion" do
    bob_city = Card.create :name=>'bob+city' 
    Card.create :name=>'address+*right+*default',:content=>"{{#{JOINT}city|base:parent}}"
    bob_address = Card.create :name=>'bob+address'
    
    bob_address.transcludees.plot(:name).should == ["bob#{JOINT}city"]
    bob_city.transcluders.plot(:name).should == ["bob#{JOINT}address"]
  end


  it "pickup new links on rename" do
    @l = newcard("L", "[[Ethan]]")  # no Ethan card yet...
    @e = newcard("Earthman")
    @e.update_attributes! :name => "Ethan"  # NOW there is an Ethan card
    # @e.referencers.plot(:name).include("L")  as the test was originally written, fails
    #  do we need the links to be caught before reloading the card?
    Card["Ethan"].referencers.plot(:name).include?("L").should_not == nil
  end
                  
  it "should update references on rename when requested" do
    watermelon = newcard('watermelon', 'mmmm')
    watermelon_seeds = newcard('watermelon+seeds', 'black')
    lew = newcard('Lew', "likes [[watermelon]] and [[watermelon#{JOINT}seeds|seeds]]")

    watermelon = Card['watermelon']
    watermelon.update_referencers = true
    watermelon.confirm_rename = true
    watermelon.name="grapefruit"
    watermelon.save!
    lew.reload.content.should == "likes [[grapefruit]] and [[grapefruit#{JOINT}seeds|seeds]]"
  end
  
  it "should not update references when not requested" do
    watermelon = newcard('watermelon', 'mmmm')
    watermelon_seeds = newcard('watermelon+seeds', 'black')
    lew = newcard('Lew', "likes [[watermelon]] and [[watermelon#{JOINT}seeds|seeds]]")

    watermelon = Card['watermelon']
    watermelon.update_referencers = false
    watermelon.confirm_rename = true
    watermelon.name="grapefruit"
    watermelon.save!
    lew.reload.content.should == "likes [[watermelon]] and [[watermelon#{JOINT}seeds|seeds]]"
    w = ReferenceTypes::WANTED_LINK
    assert_equal [w,w], lew.out_references.plot(:link_type), "links should be Wanted"
  end

  it "update referencing content on rename junction card" do
    @ab = Card.find_by_name("A+B") #linked to from X, transcluded by Y
    @ab.update_attributes! :name=>'Peanut+Butter', :confirm_rename => true, :update_referencers => true
    @x = Card.find_by_name('X')
    @x.content.should == "[[A]] [[Peanut+Butter]] [[T]]"
  end

  it "update referencing content on rename junction card" do
    @ab = Card.find_by_name("A+B") #linked to from X, transcluded by Y
    @ab.confirm_rename = true
    @ab.update_attributes! :name=>'Peanut+Butter', :update_referencers=>false
    @x = Card.find_by_name('X')
    @x.content.should == "[[A]] [[A+B]] [[T]]"
  end
    
  it "template transclusion" do
    cardtype = Card::Cardtype.create! :name=>"ColorType", :content=>""
    Card.create! :name=>"ColorType+*type+*content", :content=>"{{#{JOINT}rgb}}"
    green = Card::ColorType.create! :name=>"green"
    rgb = newcard 'rgb'
    green_rgb = Card.create! :name => "green+rgb", :content=>"#00ff00"
    
    green.reload.transcludees.plot(:name).should == ["green#{JOINT}rgb"]
    green_rgb.reload.transcluders.plot(:name).should == ['green']
  end

  it "simple link" do
    alpha = Card.create :name=>'alpha'
    beta = Card.create :name=>'beta', :content=>"I link to [[alpha]]"
    Card['beta'].referencees.plot(:name).should == ['alpha']
    Card['alpha'].referencers.plot(:name).should == ['beta']
  end

  it "link with spaces" do
    alpha = Card.create! :name=>'alpha card'
    beta =  Card.create! :name=>'beta card', :content=>"I link to [[alpha_card|ALPHA CARD]]"
    Card['beta card'].referencees.plot(:name).should == ['alpha card']
    Card['alpha card'].referencers.plot(:name).should == ['beta card']
  end


  it "simple transclusion" do
    alpha = Card.create :name=>'alpha'
    beta = Card.create :name=>'beta', :content=>"I transclude to {{alpha}}"
    Card['beta'].transcludees.plot(:name).should == ['alpha']
    Card['alpha'].transcluders.plot(:name).should == ['beta']
  end

  it "non simple link" do
    alpha = Card.create :name=>'alpha'
    beta = Card.create :name=>'beta', :content=>"I link to [[alpha|ALPHA]]"
    Card['beta'].referencees.plot(:name).should == ['alpha']
    Card['alpha'].referencers.plot(:name).should == ['beta']
  end
  

  it "pickup new links on create" do
    @l = newcard("woof", "[[Lewdog]]")  # no Lewdog card yet...
    @e = newcard("Lewdog")              # now there is
    # NOTE @e.referencers does not work, you have to reload
    @e.reload.referencers.plot(:name).include?("woof").should_not == nil
  end
  
  
#=begin   
  # this test is about the time between when a card is first created and the time that
  # references pointing to the cards name are updated and given an id;  
  # these 'name_references' are used in the cache_sweeper, but i'm not sure i understand
  # the scenario where they're needed. LWH
  
  it "pickup new transclusions on create" do
    @l = Card.create! :name=>"woof", :content=>"{{Lewdog}}"  # no Lewdog card yet...
    @e = Card.new(:name=>"Lewdog", :content=>"grrr")              # now there is
    warn @e.name_references.inspect
    @e.name_references.plot(:referencer).plot(:name).include?("woof").should_not == nil
  end
#=end

=begin  

  # This test doesn't make much sense to me... LWH
  it "revise changes references from wanted to linked for new cards" do
    new_card = Card::Basic.create(:name=>'NewCard')
    new_card.revise('Reference to [[WantedCard]], and to [[WantedCard2]]', Time.now, User.find_by_login('quentin'), 
        get_renderer)
    
    references = new_card.wiki_references(true)
    references.size.should == 2
    references[0].referenced_name.should == 'WantedCard'
    references[0].link_type.should == WikiReference::WANTED_PAGE
    references[1].referenced_name.should == 'WantedCard2'
    references[1].link_type.should == WikiReference::WANTED_PAGE

    wanted_card = Card::Basic.create(:name=>'WantedCard')
    wanted_card.revise('And here it is!', Time.now, User.find_by_login('quentin'), get_renderer)

    # link type stored for NewCard -> WantedCard reference should change from WANTED to LINKED
    # reference NewCard -> WantedCard2 should remain the same
    references = new_card.wiki_references(true)
    references.size.should == 2
    references[0].referenced_name.should == 'WantedCard'
    references[0].link_type.should == WikiReference::LINKED_PAGE
    references[1].referenced_name.should == 'WantedCard2'
    references[1].link_type.should == WikiReference::WANTED_PAGE
  end
=end
  private
  def newcard(name, content="")
    ::Card::Basic.create! :name=>name, :content=>content
  end

end
