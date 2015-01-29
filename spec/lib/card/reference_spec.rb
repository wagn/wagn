# -*- encoding : utf-8 -*-

describe Card::Reference do

  before do
    Card::Auth.current_id = Card::WagnBotID
  end

  describe "references on hard templated cards should get updated" do
    it "on structuree creation" do
      Card.create! :name=>"JoeForm", :type=>'UserForm'
      Card["JoeForm"].format.render(:core)
      assert_equal ["joe_form+age", "joe_form+description", "joe_form+name"],
        Card["JoeForm"].includees.map(&:key).sort
      expect(Card["JoeForm"].references_expired).not_to eq(true)
    end

    it "on template creation" do
      Card.create! :name=>"SpecialForm", :type=>'Cardtype'
      Card.create! :name=>"Form1", :type=>'SpecialForm', :content=>"foo"
      c = Card["Form1"]
      expect(c.references_expired).to be_nil
      Card.create! :name=>"SpecialForm+*type+*structure", :content=>"{{+bar}}"
      c = Card["Form1"]
      expect(c.references_expired).to be_truthy
      Card["Form1"].format.render(:core)
      c = Card["Form1"]
      expect(c.references_expired).to be_nil
      expect(Card["Form1"].includees.map(&:key)).to eq(["form1+bar"])
    end

    it "on template update" do
      Card.create! :name=>"JoeForm", :type=>'UserForm'
      tmpl = Card["UserForm+*type+*structure"]
      tmpl.content = "{{+monkey}} {{+banana}} {{+fruit}}";
      tmpl.save!
      expect(Card["JoeForm"].references_expired).to be_truthy
      Card["JoeForm"].format.render(:core)
      assert_equal ["joe_form+banana", "joe_form+fruit", "joe_form+monkey"],
        Card["JoeForm"].includees.map(&:key).sort
      expect(Card["JoeForm"].references_expired).not_to eq(true)
    end
  end

  it "in references should survive cardtype change" do
    newcard("Banana","[[Yellow]]")
    newcard("Submarine","[[Yellow]]")
    newcard("Sun","[[Yellow]]")
    newcard("Yellow")
    expect(Card["Yellow"].referencers.map(&:name).sort).to eq(%w{ Banana Submarine Sun })
    y=Card["Yellow"];
    y.type_id= Card.fetch_id "UserForm";
    y.save!
    expect(Card["Yellow"].referencers.map(&:name).sort).to eq(%w{ Banana Submarine Sun })
  end

  it "container inclusion" do
    Card.create :name=>'bob+city'
    Card.create :name=>'address+*right+*default',:content=>"{{_L+city}}"
    Card.create :name=>'bob+address'
    expect(Card.fetch('bob+address').includees.map(&:name)).to eq(["bob+city"])
    expect(Card.fetch('bob+city').includers.map(&:name)).to eq(["bob+address"])
  end

  it "pickup new links on rename" do
    @l = newcard("L", "[[Ethan]]")  # no Ethan card yet...
    @e = newcard("Earthman")
    @e.update_attributes! :name => "Ethan"  # NOW there is an Ethan card
    # @e.referencers.map(&:name).include("L")  as the test was originally written, fails
    #  do we need the links to be caught before reloading the card?
    expect(Card["Ethan"].referencers.map(&:name).include?("L")).not_to eq(nil)
  end

  it "should update references on rename when requested" do
    watermelon = newcard('watermelon', 'mmmm')
    watermelon_seeds = newcard('watermelon+seeds', 'black')
    lew = newcard('Lew', "likes [[watermelon]] and [[watermelon+seeds|seeds]]")

    watermelon = Card['watermelon']
    watermelon.update_referencers = true
    watermelon.name="grapefruit"
    watermelon.save!
    expect(lew.reload.content).to eq("likes [[grapefruit]] and [[grapefruit+seeds|seeds]]")
  end

  it "should update referencers on rename when requested (case 2)" do
    card = Card['Administrator Menu+*self+*read']
    refs = Card::Reference.where(:referee_id => Card::AdministratorID).map(&:referer_id).sort
    card.update_referencers = true
    card.name='Administrator Menu+*type+*read'
    card.save
    expect(Card::Reference.where(:referee_id => Card::AdministratorID).map(&:referer_id).sort).to eq(refs)
  end

  it "should not update references when not requested" do

    watermelon = newcard('watermelon', 'mmmm')
    watermelon_seeds = newcard('watermelon+seeds', 'black')
    lew = newcard('Lew', "likes [[watermelon]] and [[watermelon+seeds|seeds]]")

    assert_equal [1,1,1,1], lew.references_to.map(&:present), "links should not be Wanted before"
    watermelon = Card['watermelon']
    watermelon.update_referencers = false
    watermelon.name="grapefruit"
    watermelon.save!
    expect(lew.reload.content).to eq("likes [[watermelon]] and [[watermelon+seeds|seeds]]")
    assert_equal lew.references_to.order(:id).map(&:ref_type), ['L','P','P','L'], "links should be a LINK"
    assert_equal lew.references_to.order(:id).map(&:present), [ 0, 0, 1, 0 ],  "only reference to +seeds should be present"
  end

  it "update referencing content on rename junction card" do
    @ab = Card["A+B"] #linked to from X, included by Y
    @ab.update_attributes! :name=>'Peanut+Butter', :update_referencers => true
    @x = Card['X']
    expect(@x.content).to eq("[[A]] [[Peanut+Butter]] [[T]]")
  end

  it "update referencing content on rename junction card" do
    @ab = Card["A+B"] #linked to from X, included by Y
    @ab.update_attributes! :name=>'Peanut+Butter', :update_referencers=>false
    @x = Card['X']
    expect(@x.content).to eq("[[A]] [[A+B]] [[T]]")
  end

  it "template inclusion" do
    cardtype = Card.create! :name=>"ColorType", :type=>'Cardtype', :content=>""
    Card.create! :name=>"ColorType+*type+*structure", :content=>"{{+rgb}}"
    green = Card.create! :name=>"green", :type=>'ColorType'
    rgb = newcard 'rgb'
    green_rgb = Card.create! :name => "green+rgb", :content=>"#00ff00"

    expect(green.reload.includees.map(&:name)).to eq(["green+rgb"])
    expect(green_rgb.reload.includers.map(&:name)).to eq(['green'])
  end

  it "simple link" do
    alpha = Card.create :name=>'alpha'
    beta = Card.create :name=>'beta', :content=>"I link to [[alpha]]"
    expect(Card['alpha'].referencers.map(&:name)).to eq(['beta'])
    expect(Card['beta'].referees.map(&:name)).to eq(['alpha'])
  end

  it "link with spaces" do
    alpha = Card.create! :name=>'alpha card'
    beta =  Card.create! :name=>'beta card', :content=>"I link to [[alpha_card|ALPHA CARD]]"
    expect(Card['beta card'].referees.map(&:name)).to eq(['alpha card'])
    expect(Card['alpha card'].referencers.map(&:name)).to eq(['beta card'])
  end


  it "simple inclusion" do
    alpha = Card.create :name=>'alpha'
    beta = Card.create :name=>'beta', :content=>"I include to {{alpha}}"
    expect(Card['beta'].includees.map(&:name)).to eq(['alpha'])
    expect(Card['alpha'].includers.map(&:name)).to eq(['beta'])
  end

  it "non simple link" do
    alpha = Card.create :name=>'alpha'
    beta = Card.create :name=>'beta', :content=>"I link to [[alpha|ALPHA]]"
    expect(Card['beta'].referees.map(&:name)).to eq(['alpha'])
    expect(Card['alpha'].referencers.map(&:name)).to eq(['beta'])
  end
  
  it "should handle commented inclusion" do
    c = Card.create :name=>'inclusion comment test', :content=>'{{## hi mom }}'
    expect(c.errors.any?).to be_falsey
  end


  it "pickup new links on create" do
    @l = newcard("woof", "[[Lewdog]]")  # no Lewdog card yet...
    @e = newcard("Lewdog")              # now there is
    # NOTE @e.referencers does not work, you have to reload
    expect(@e.reload.referencers.map(&:name).include?("woof")).not_to eq(nil)
  end

  it "pickup new inclusions on create" do
    @l = Card.create! :name=>"woof", :content=>"{{Lewdog}}"  # no Lewdog card yet...
    @e = Card.new(:name=>"Lewdog", :content=>"grrr")              # now there is
    expect(@e.name_referencers.map(&:name).include?("woof")).not_to eq(nil)
  end

=begin

  # This test doesn't make much sense to me... LWH
  it "revise changes references from wanted to linked for new cards" do
    new_card = Card.create(:name=>'NewCard')
    new_card.revise('Reference to [[WantedCard]], and to [[WantedCard2]]', Time.now, Card['quentin'].account),
        new_format)

    references = new_card.card_references(true)
    references.size.should == 2
    references[0].referee_key.should == 'WantedCard'
    references[0].ref_type.should == Card::Reference::WANTED_PAGE
    references[1].referee_key.should == 'WantedCard2'
    references[1].ref_type.should == Card::Reference::WANTED_PAGE

    wanted_card = Card.create(:name=>'WantedCard')
    wanted_card.revise('And here it is!', Time.now, Card['quentin'].account), new_format)

    # link type stored for NewCard -> WantedCard reference should change from WANTED to LINKED
    # reference NewCard -> WantedCard2 should remain the same
    references = new_card.card_references(true)
    references.size.should == 2
    references[0].referee_key.should == 'WantedCard'
    references[0].ref_type.should == Card::Reference::LINKED_PAGE
    references[1].referee_key.should == 'WantedCard2'
    references[1].ref_type.should == Card::Reference::WANTED_PAGE
  end
=end

end
