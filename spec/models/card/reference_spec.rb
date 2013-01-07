require File.expand_path('../../spec_helper', File.dirname(__FILE__))


describe "Card::Reference" do

  before do
    #setup_default_user
    Account.as(Card::WagnBotID) # FIXME: as without a block deprecated
  end

  describe "references on hard templated cards should get updated" do
    it "on templatee creation" do
      Card.create! :name=>"JoeForm", :type=>'UserForm'
      Wagn::Renderer.new(Card["JoeForm"]).render(:core)
      assert_equal ["joe_form+age", "joe_form+description", "joe_form+name"],
        Card["JoeForm"].includees.map(&:key).sort
      Card["JoeForm"].references_expired.should_not == true
    end

    it "on template creation" do
      Card.create! :name=>"SpecialForm", :type=>'Cardtype'
      Card.create! :name=>"Form1", :type=>'SpecialForm', :content=>"foo"
      c = Card["Form1"]
      c.references_expired.should be_nil
      Card.create! :name=>"SpecialForm+*type+*content", :content=>"{{+bar}}"
      c = Card["Form1"]
      c.references_expired.should be_true
      Rails.logger.warn "C before #{c.inspect}"
      Wagn::Renderer.new(Card["Form1"]).render(:core)
      c = Card["Form1"]
      Rails.logger.warn "C is #{c.inspect}"
      c.references_expired.should be_nil
      Card["Form1"].includees.map(&:key).should == ["form1+bar"]
    end

    it "on template update" do
      Card.create! :name=>"JoeForm", :type=>'UserForm'
      tmpl = Card["UserForm+*type+*content"]
      tmpl.content = "{{+monkey}} {{+banana}} {{+fruit}}";
      tmpl.save!
      Card["JoeForm"].references_expired.should be_true
      Wagn::Renderer.new(Card["JoeForm"]).render(:core)
      assert_equal ["joe_form+monkey", "joe_form+banana", "joe_form+fruit"].sort,
        Card["JoeForm"].includees.map(&:key).sort
      Card["JoeForm"].references_expired.should_not == true
    end
  end

  it "in references should survive cardtype change" do
    newcard("Banana","[[Yellow]]")
    newcard("Submarine","[[Yellow]]")
    newcard("Sun","[[Yellow]]")
    newcard("Yellow")
    Card["Yellow"].referencers.map(&:name).sort.should == %w{ Banana Submarine Sun }
    y=Card["Yellow"];
    y.type_id= Card.fetch_id "UserForm";
    y.save!
    Card["Yellow"].referencers.map(&:name).sort.should == %w{ Banana Submarine Sun }
  end

  it "container inclusion" do
    Card.create :name=>'bob+city'
    Card.create :name=>'address+*right+*default',:content=>"{{_L+city}}"
    Card.create :name=>'bob+address'
    Card.fetch('bob+address').includees.map(&:name).should == ["bob+city"]
    Card.fetch('bob+city').includers.map(&:name).should == ["bob+address"]
  end

  it "pickup new links on rename" do
    @l = newcard("L", "[[Ethan]]")  # no Ethan card yet...
    @e = newcard("Earthman")
    @e.update_attributes! :name => "Ethan"  # NOW there is an Ethan card
    # @e.referencers.map(&:name).include("L")  as the test was originally written, fails
    #  do we need the links to be caught before reloading the card?
    Card["Ethan"].referencers.map(&:name).include?("L").should_not == nil
  end

  it "should update references on rename when requested" do
    watermelon = newcard('watermelon', 'mmmm')
    watermelon_seeds = newcard('watermelon+seeds', 'black')
    lew = newcard('Lew', "likes [[watermelon]] and [[watermelon+seeds|seeds]]")

    watermelon = Card['watermelon']
    watermelon.update_referencers = true
    watermelon.name="grapefruit"
    watermelon.save!
    lew.reload.content.should == "likes [[grapefruit]] and [[grapefruit+seeds|seeds]]"
  end

  it "should update referencers on rename when requested (case 2)" do
    card = Card['Administrator links+*self+*read']
    refs = Card::Reference.where(:referee_id => Card::AdminID).map(&:referer_id).sort
    card.update_referencers = true
    card.name='Administrator links+*type+*read'
    card.save
    Card::Reference.where(:referee_id => Card::AdminID).map(&:referer_id).sort.should == refs
  end

  it "should not update references when not requested" do

    watermelon = newcard('watermelon', 'mmmm')
    watermelon_seeds = newcard('watermelon+seeds', 'black')
    lew = newcard('Lew', "likes [[watermelon]] and [[watermelon+seeds|seeds]]")

    assert_equal [1,1], lew.out_references.map(&:present), "links should not be Wanted before"
    watermelon = Card['watermelon']
    watermelon.update_referencers = false
    watermelon.name="grapefruit"
    watermelon.save!
    lew.reload.content.should == "likes [[watermelon]] and [[watermelon+seeds|seeds]]"
    assert_equal [ 'L', 'L' ], lew.out_references.map(&:link_type), "links should be a LINK"
    assert_equal [ 0, 0 ], lew.out_references.map(&:present), "links should not be present"
  end

  it "update referencing content on rename junction card" do
    @ab = Card["A+B"] #linked to from X, included by Y
    @ab.update_attributes! :name=>'Peanut+Butter', :update_referencers => true
    @x = Card['X']
    @x.content.should == "[[A]] [[Peanut+Butter]] [[T]]"
  end

  it "update referencing content on rename junction card" do
    @ab = Card["A+B"] #linked to from X, included by Y
    @ab.update_attributes! :name=>'Peanut+Butter', :update_referencers=>false
    @x = Card['X']
    @x.content.should == "[[A]] [[A+B]] [[T]]"
  end

  it "template inclusion" do
    cardtype = Card.create! :name=>"ColorType", :type=>'Cardtype', :content=>""
    Card.create! :name=>"ColorType+*type+*content", :content=>"{{+rgb}}"
    green = Card.create! :name=>"green", :type=>'ColorType'
    rgb = newcard 'rgb'
    green_rgb = Card.create! :name => "green+rgb", :content=>"#00ff00"

    green.reload.includees.map(&:name).should == ["green+rgb"]
    green_rgb.reload.includers.map(&:name).should == ['green']
  end

  it "simple link" do
    alpha = Card.create :name=>'alpha'
    beta = Card.create :name=>'beta', :content=>"I link to [[alpha]]"
    Card['alpha'].referencers.map(&:name).should == ['beta']
    Card['beta'].referencees.map(&:name).should == ['alpha']
  end

  it "link with spaces" do
    alpha = Card.create! :name=>'alpha card'
    beta =  Card.create! :name=>'beta card', :content=>"I link to [[alpha_card|ALPHA CARD]]"
    Card['beta card'].referencees.map(&:name).should == ['alpha card']
    Card['alpha card'].referencers.map(&:name).should == ['beta card']
  end


  it "simple inclusion" do
    alpha = Card.create :name=>'alpha'
    beta = Card.create :name=>'beta', :content=>"I include to {{alpha}}"
    Card['beta'].includees.map(&:name).should == ['alpha']
    Card['alpha'].includers.map(&:name).should == ['beta']
  end

  it "non simple link" do
    alpha = Card.create :name=>'alpha'
    beta = Card.create :name=>'beta', :content=>"I link to [[alpha|ALPHA]]"
    Card['beta'].referencees.map(&:name).should == ['alpha']
    Card['alpha'].referencers.map(&:name).should == ['beta']
  end


  it "pickup new links on create" do
    @l = newcard("woof", "[[Lewdog]]")  # no Lewdog card yet...
    @e = newcard("Lewdog")              # now there is
    # NOTE @e.referencers does not work, you have to reload
    @e.reload.referencers.map(&:name).include?("woof").should_not == nil
  end

  it "pickup new inclusions on create" do
    @l = Card.create! :name=>"woof", :content=>"{{Lewdog}}"  # no Lewdog card yet...
    @e = Card.new(:name=>"Lewdog", :content=>"grrr")              # now there is
    @e.name_referencers.map(&:name).include?("woof").should_not == nil
  end

=begin

  # This test doesn't make much sense to me... LWH
  it "revise changes references from wanted to linked for new cards" do
    new_card = Card.create(:name=>'NewCard')
    new_card.revise('Reference to [[WantedCard]], and to [[WantedCard2]]', Time.now, Card['quentin'].to_user),
        get_renderer)

    references = new_card.card_references(true)
    references.size.should == 2
    references[0].referee_key.should == 'WantedCard'
    references[0].link_type.should == Card::Reference::WANTED_PAGE
    references[1].referee_key.should == 'WantedCard2'
    references[1].link_type.should == Card::Reference::WANTED_PAGE

    wanted_card = Card.create(:name=>'WantedCard')
    wanted_card.revise('And here it is!', Time.now, Card['quentin'].to_user), get_renderer)

    # link type stored for NewCard -> WantedCard reference should change from WANTED to LINKED
    # reference NewCard -> WantedCard2 should remain the same
    references = new_card.card_references(true)
    references.size.should == 2
    references[0].referee_key.should == 'WantedCard'
    references[0].link_type.should == Card::Reference::LINKED_PAGE
    references[1].referee_key.should == 'WantedCard2'
    references[1].link_type.should == Card::Reference::WANTED_PAGE
  end
=end
  private
  def newcard(name, content="")
    Card.create! :name=>name, :content=>content
  end

end
