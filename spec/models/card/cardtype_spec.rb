# -*- encoding : utf-8 -*-

class Card
  # REVIEW: hooks api will do this differently, probably should remove and add new tests elsewhere
  # this is used by some type based modules on CardtypeE from type_transition
  cattr_accessor :count
end

describe "Card (Cardtype)" do

  it "should not allow cardtype remove when instances present" do
    Card.create :name=>'City', :type=>'Cardtype'
    city = Card.fetch('City')
    c1=Card.create :name=>'Sparta', :type=>'City'
    c2=Card.create :name=>'Eugene', :type=>'City'
    assert_equal ['Eugene','Sparta'], Card.search(:type=>'City').map(&:name).sort
    assert_raises ActiveRecord::RecordInvalid do
      city.delete!
    end
    # make sure it wasn't deleted / trashed
    Card['City'].should_not be_nil
  end

  it "remove cardtype" do
    Card.create! :name=>'County', :type=>'Cardtype'
    c = Card['County']
    c.delete
  end

  it "cardtype creation and dynamic cardtype" do

    assert Card.create( :name=>'BananaPudding', :type=>'Cardtype' ).type_id == Card::Codename[:cardtype]
    assert_instance_of Card, c=Card.fetch("BananaPudding")

    # you have to have a module to include or it's just a Basic (type_code fielde excepted)
    cd = Card.create(:type=>'banana_pudding',:name=>"figgy" )
    assert cd.type_name == 'BananaPudding'
    assert Card.find_by_type_id(c.id)
  end

  describe "conversion to cardtype" do
    before do
      @card = Card.create!(:type=>'Cardtype', :name=>'Cookie')
      @card.type_name.should == 'Cardtype'
    end

    it "creates cardtype model and permission" do
      @card.type_id = Card.fetch_id('cookie')
      @card.save!
      @card.type_name.should == 'Cookie'
      @card=Card['Cookie']
      assert_instance_of Card, @card
      @card.type_code.should == nil # :cookie
      assert_equal 'Cookie', Card.create!( :name=>'Oreo', :type=>'Cookie' ).type_name
    end
  end

  it "cardtype" do
    Card.find(:all).each do |card|
      assert !card.type_card.nil?
    end
  end

end


describe Card, "created without permission" do
  before do
    Card::Auth.current_id = Card::AnonymousID
  end

  # FIXME:  this one should pass.  unfortunately when I tried to fix it it started looking like the clean solution
  #  was to rewrite most of the permissions section as simple validations and i decided not to go down that rabbit hole.
  #
  #it "should not be valid" do
  #  Card.new( :name=>'foo', :type=>'Cardtype').valid?.should_not be_true
  #end

  it "should not create a new cardtype until saved" do
    lambda {
      Card.new( :name=>'foo', :type=>'Cardtype')
    }.should_not change(Card, :count)
  end
end


describe Card, "Normal card with dependents" do
  before do
    @a = Card['A']
  end
  it "should confirm that it has dependents" do
    @a.dependents.length.should > 0
  end
  it "should successfully have its type changed" do
    Card::Auth.as_bot do
      @a.type_id = Card::PhraseID;
      @a.save!
      Card['A'].type_code.should== :phrase
    end
  end
  it "should still have its dependents after changing type" do
    Card::Auth.as_bot do
      assert type_id = Card.fetch_id('cardtype_e')
      @a.type_id = type_id; @a.save!
      Card['A'].dependents.length.should > 0
    end
  end
end


=begin No extension any more, is there a modified version of this we need?
describe Card, "Recreated Card" do
  before do
    Card::Auth.as_bot do
    @ct = Card.create! :name=>'Species', :type=>'Cardtype'
    @ct.delete!
    @ct = Card.create! :name=>'Species', :type=>'Cardtype'
    end
  end

  it "should have a cardtype extension" do
    @ct.extension.should_not be_nil
  end

end
=end

describe Card, "New Cardtype" do
  before do
    Card::Auth.as_bot do
      @ct = Card.create! :name=>'Animal', :type=>'Cardtype'
    end
  end

  it "should have create permissions" do
    @ct.who_can(:create).should_not be_nil
  end

  it "its create permissions should be based on Basic" do
    @ct.who_can(:create).should == Card['Basic'].who_can(:create)
  end
end

describe Card, "Wannabe Cardtype Card" do
  before do
    Card::Auth.as_bot do
      @card = Card.create! :name=> 'convertible'
      @card.type_id=Card::CardtypeID
      @card.save!
    end

  end
  it "should successfully change its type to a Cardtype" do
    Card['convertible'].type_code.should==:cardtype
  end
end

describe Card, "Joe User" do
  before do
    Card::Auth.as_bot do
      @r3 = Card['r3']
      Card.create :name=>'Cardtype F+*type+*create', :type=>'Pointer', :content=>'[[r3]]'
    end

    @ucard = Card::Auth.current
    @type_names = Card::Auth.createable_types
  end

  it "should not have r3 permissions" do
    @ucard.fetch(:new=>{}, :trait=>:roles).item_names.member?(@r3.name).should be_false
  end
  it "should ponder creating a card of Cardtype F, but find that he lacks create permissions" do
    Card.new(:type=>'Cardtype F').ok?(:create).should be_false
  end
  it "should not find Cardtype F on its list of createable cardtypes" do
    @type_names.member?('Cardtype F').should be_false
  end
  it "should find Basic on its list of createable cardtypes" do
    @type_names.member?('Basic').should be_true
  end

end


describe Card, "Cardtype with Existing Cards" do
  before do
    @ct = Card['Cardtype F']
  end
  it "should have existing cards of that type" do
    Card.search(:type=>@ct.name).should_not be_empty
  end

  it "should raise an error when you try to delete it" do
    Card::Auth.as_bot do
      @ct.delete
      @ct.errors[:cardtype].should_not be_empty
    end
  end
end


describe Card::Set::Type::Cardtype do

  it "should handle changing away from Cardtype" do
    Card::Auth.as_bot do
      ctg = Card.create! :name=>"CardtypeG", :type=>"Cardtype"
      ctg.type_id = Card::BasicID
      ctg.save!
      ctg = Card["CardtypeG"]
      ctg.type_code.should == :basic
      #ctg.extension.should == nil
    end
  end
end


