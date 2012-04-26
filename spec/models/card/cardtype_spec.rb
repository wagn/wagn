require File.expand_path('../../spec_helper', File.dirname(__FILE__))

class Card
  # REVIEW: hooks api will do this differently, probably should remove and add new tests elsewhere
  # this is used by some type based modules on CardtypeE from type_transition
  cattr_accessor :count
end

describe "Card (Cardtype)" do
  
  before do
    Card.as :joe_user
  end

  it "should not allow cardtype remove when instances present" do
    Card.create :name=>'City', :type=>'Cardtype'
    #Card::Codename.reset_cache
    city = Card.fetch('City')
    c1=Card.create :name=>'Sparta', :type=>'City'
    c2=Card.create :name=>'Eugene', :type=>'City'
    assert_equal ['Eugene','Sparta'], Card.search(:type=>'City').plot(:name).sort
    assert_raises Wagn::Oops do
      city.destroy!
    end                             
    # make sure it wasn't destroyed / trashed
    Card.find_by_name('City').should_not be_nil
  end
  
  it "remove cardtype" do
    Card.create! :name=>'County', :type=>'Cardtype'
    c = Card.find_by_name('County')
    c.destroy
    Card.type_id_from_code('county').should == nil
  end
  
  it "cardtype creation and dynamic cardtype" do
    
    assert Card.create( :name=>'BananaPudding', :type=>'Cardtype' ).type_id == Card.type_id_from_code('Cardtype')
    assert_instance_of Card, c=Card.fetch("BananaPudding")
    assert Integer===(tid=Card.type_id_from_code("banana_pudding"))

    # you have to have a module to include or it's just a Basic (typecode fielde excepted)
    assert Card.create(:typecode=>'banana_pudding',:name=>"figgy" ).typename == 'BananaPudding'
    assert Card.find_by_type_id(tid)
  end

  describe "conversion to cardtype" do
    before do
      @card = Card.create!(:type=>'Cardtype', :name=>'Cookie')
      @card.typename.should == 'Cardtype'
    end
    
    it "creates cardtype model and permission" do
      @card.type_id = Card.type_id_from_code('cookie')
      @card.save!
      @card.typename.should == 'Cookie'
      @card=Card['Cookie']
      assert_instance_of Card, @card
      @card.typecode.should == "cookie"
      assert_equal 'Cookie', Card.create!( :name=>'Oreo', :type=>'Cookie' ).typename
    end
  end
  
  it "cardtype" do
    Card.find(:all).each do |card|
      assert !card.type_card.nil?
    end
  end
  
end



describe Card, "classname_validation" do
  it "should create valid classnames" do
    Card.klassname_for("$SBJgg%%od").should == "SBJggOd"
  end
  
  it "should create incremented classnames when first choice is taken" do
    #Card.klassname_for("User").should thow an error
    #Card.klassname_for("Basic").should thow an error
    Card.klassname_for("Novelicious").should == "Novelicious"
#    Card.klassname_for('Process').should == 'Process1'
  end
end                  

describe Card, "created without permission" do
  before do
    Card.user= Card::AnonID
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


describe Card, "Normal card with junctions" do
  before do
    Card.as(Card::WagbotID) 
    @a = Card['A']
  end
  it "should confirm that it has junctions" do
    @a.junctions.length.should > 0
  end
  it "should successfull have its type changed" do
    @a.type_id = Card::NumberID;
    @a.save!
    Card['A'].typecode.should== 'number'
  end
  it "should still have its junctions after changing type" do
    assert type_id = Card.type_id_from_code('cardtype_e')
    @a.type_id = type_id; @a.save!
    Card['A'].junctions.length.should > 0
  end
end


=begin No extension any more, is there a modified version of this we need?
describe Card, "Recreated Card" do
  before do
    Card.as(Card::WagbotID) 
    @ct = Card.create! :name=>'Species', :type=>'Cardtype'
    @ct.destroy!
    @ct = Card.create! :name=>'Species', :type=>'Cardtype'
  end
  
  it "should have a cardtype extension" do
    @ct.extension.should_not be_nil
  end
  
end
=end

describe Card, "New Cardtype" do
  before do
    Card.as(Card::WagbotID) 
    @ct = Card.create! :name=>'Animal', :type=>'Cardtype'
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
    Card.as(Card::WagbotID) 
    @card = Card.create! :name=> 'convertible'
    @card.type_id=Card::CardtypeID
    @card.save!
    
  end
  it "should successfully change its type to a Cardtype" do
    Card['convertible'].typecode.should=='cardtype'
  end
  #it "should have an extension" do
  #  Card['convertible'].extension.should_not== nil
  #end
end

describe User, "Joe User" do
  before do
    Card.as(Card::WagbotID) 
    @r3 = Card['r3']

    Card.create :name=>'Cardtype F+*type+*create', :type=>'Pointer', :content=>'[[r3]]'
    
#    @ctf.permit(:create, @r3)
#    @ctf.save!

    Card.as :joe_user
    @user = User.user
    @ucard = Card[@user.card_id]
    #Card::Codename.reset_cache
    @typenames = Card.createable_types
    #@typenames = Card.createable_types.map{ |ct| ct[:name] }
  end

  it "should not have r3 permissions" do
    @ucard.trait_card(:roles).item_names.member?(@r3.name).should be_false
  end
  it "should ponder creating a card of Cardtype F, but find that he lacks create permissions" do
    Card.new(:type=>'Cardtype F').ok?(:create).should be_false
  end
  it "should not find Cardtype F on its list of createable cardtypes" do
    #pending "createable_types"
    @typenames.member?('Cardtype F').should be_false
  end
  it "should find Basic on its list of createable cardtypes" do
    #pending "createable_types"
    #warn "crtble tps #{@typenames.inspect}"
    @typenames.member?('Basic').should be_true
  end
  
end


describe Card, "Cardtype with Existing Cards" do
  before do
    Card.as(Card::WagbotID) 
    @ct = Card['Basic']
  end
  it "should have existing cards of that type" do
    Card.search(:type=>@ct.name).should_not be_empty
  end

  it "should raise an error when you try to delete it" do
    @ct.destroy
    @ct.errors[:cardtype].should_not be_empty
  end
end


describe Wagn::Set::Type::Cardtype do
  before do
    Card.as(Card::WagbotID)
  end
  
  it "should handle changing away from Cardtype" do
    ctg = Card.create! :name=>"CardtypeG", :type=>"Cardtype"
    ctg.type_id = Card::BasicID
    ctg.save!
    ctg = Card["CardtypeG"]
    ctg.typecode.should == 'basic'
    #ctg.extension.should == nil
  end
end


