require File.dirname(__FILE__) + '/../../spec_helper'

describe "Card::Cardtype" do
  
  before do
    User.as :joe_user
  end
  
  it "should not allow cardtype remove when instances present" do
    Card::Cardtype.create :name=>'City'
    city = Card::Cardtype.find_by_name('City')
    Card::City.create :name=>'Sparta'
    Card::City.create :name=>'Eugene'
    assert_equal ['Eugene','Sparta'], Card.search(:type=>'City').plot(:name).sort
    assert_raises Wagn::Oops do
      city.destroy!
    end                             
    # make sure it wasn't destroyed / trashed
    Card.find_by_name('City').should_not be_nil
  end
  
  it "remove cardtype" do
    Card::Cardtype.create! :name=>'County'
    city = Card::Cardtype.find_by_name('County')
    #warn "extension: #{city.extension}"
    city.destroy
    Cardtype.find_by_class_name('County').should == nil
  end
  
  it "cardtype creation and dynamic cardtype" do
    assert_raises( NameError ) do
      Card::BananaPudding.create :name=>"figgy"
    end
    assert_instance_of Card::Cardtype, Card::Cardtype.create( :name=>'BananaPudding' )
    assert_instance_of Cardtype, Card.find_by_name("BananaPudding").extension
    assert_instance_of Cardtype, Cardtype.find_by_class_name("BananaPudding")    
    assert_instance_of Card::BananaPudding, Card::BananaPudding.create( :name=>"figgy" )
  end

  describe "conversion to cardtype" do
    before do
      @card = Card.create!(:name=>'Cookie')
      @card.cardtype.should == 'Basic'      
    end
    
    it "creates cardtype model and permission" do
      @card.cardtype = 'Cardtype'
      @card.save!    
      Cardtype.name_for('Cookie').should == 'Cookie'
      @card=Card['Cookie']
      assert_instance_of Cardtype, @card.extension
      Permission.find_by_card_id_and_task(@card.id, 'create').should_not be_nil
      assert_equal 'Cookie', Card.create!( :name=>'Oreo', :type=>'Cookie' ).cardtype
    end
  end
  
  it "cardtype" do
    Card.find(:all).each do |card|
      assert_instance_of Card::Cardtype, card.cardtype
    end
  end
  
end



describe Card, "codename_generation" do
  it "should create valid classnames" do
    Card.generate_codename_for("$SBJgg%%od").should == "SBJggOd"
  end
  
  it "should create incremented classnames when first choice is taken" do
    Card.generate_codename_for("User").should == "User1"
    Card.generate_codename_for('Process').should == 'Process1'
  end
end                  

describe Card, "created without permission" do
  before do
    User.current_user = :anonymous
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
    }.should_not change(Cardtype, :count) 
  end
end


describe Card, ".class_for" do
  it "should find valid types" do
    Card.class_for('basic', :cardname).should == Card::Basic
    Card.class_for('Cardtype', :codename).should == Card::Cardtype
    Card.class_for('Date').should == Card::Date
  end
  
  it "should return nil for invalid type" do
    Card.class_for("mumbo-jumbo", :cardname).should be_nil
    Card.class_for('$d_foo#adfa', :codename).should be_nil
  end
 
end


describe Card, "Card changed to become a Cardtype" do
  before do
    User.as :wagbot 
    @a = Card['A']
    @a.cardtype = 'Cardtype'
    @a.save!
  end
  it "should have a create permission set" do
    Card['A'].who_can(:create).should_not == nil
  end
end

describe Card, "Normal card with junctions" do
  before do
    User.as :wagbot 
    @a = Card['A']
  end
  it "should confirm that it has junctions" do
    @a.junctions.length.should > 0
  end
  it "should successfull have its type changed" do
    @a.cardtype = 'Number'; @a.save!
    Card['A'].cardtype.should== 'Number'
  end
  it "should still have its junctions after changing type" do
    @a.cardtype = 'CardtypeE'; @a.save!
    Card['A'].junctions.length.should > 0
  end
end


describe Card, "Recreated Card" do
  before do
    User.as :wagbot 
    @ct = Card::Cardtype.create! :name=>'Species'
    @ct.destroy!
    @ct = Card::Cardtype.create! :name=>'Species'
  end
  
  it "should have a cardtype extension" do
    @ct.extension.should_not be_nil
  end
  
end

describe Card, "New Cardtype" do
  before do
    User.as :wagbot 
    @ct = Card::Cardtype.create! :name=>'Animal'
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
    User.as :wagbot 
    @card = Card.create! :name=> 'convertible'
    @card.cardtype='Cardtype'
    @card.save!
    
  end
  it "should successfully change its type to a Cardtype" do
    Card['convertible'].cardtype.should=='Cardtype'
  end
  it "should have an extension" do
    Card['convertible'].extension.should_not== nil
  end
end

describe User, "Joe User" do
  before do
    User.as :wagbot 
    @r3 = Role[:r3]

    @ctf = Card['Cardtype F']
    @ctf.permit(:create, @r3)
    @ctf.save!

    User.as :joe_user
    @user = User[:joe_user]
    Cardtype.reset_cache
    @cardtype_names = Cardtype.createable_cardtypes.map{ |ct| ct[:name] }
  end

  it "should not have r3 permissions" do
    @user.roles.member?(@r3).should be_false
  end
  it "should ponder creating a card of Cardtype F, but find that he lacks create permissions" do
    @ctf.ok?(:create).should be_false
  end
  it "should not find Cardtype F on its list of createable cardtypes" do
    @cardtype_names.member?('Cardtype F').should be_false
  end
  it "should find Basic on its list of createable cardtypes" do
    @cardtype_names.member?('Basic').should be_true
  end
  
end


describe Card, "Cardtype with Existing Cards" do
  before do
    User.as :wagbot 
    @ct = Card['Basic']
  end
  it "should have existing cards of that type" do
    @ct.me_type.find(:all).should_not be_empty
  end

  it "should raise an error when you try to delete it" do
    @ct.destroy
    @ct.errors.on(:type).should_not be_empty
  end
end


describe Card::Cardtype do
  before do
    User.as :wagbot
  end
  
  it "should handle changing away from Cardtype" do
    ctg = Card.create! :name=>"CardtypeG", :type=>"Cardtype"
    ctg.cardtype = 'Basic'
    ctg.save!
    ctg = Card["CardtypeG"]
    ctg.cardtype.should == 'Basic'
    ctg.extension.should == nil
  end
end


