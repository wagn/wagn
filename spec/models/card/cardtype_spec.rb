require File.dirname(__FILE__) + '/../../spec_helper'


describe Card, "codename_generation" do
  it "should create valid classnames" do
    Card.generate_codename_for("$SBJgg%%od").should == "SBJggOd"
  end
  
  it "should create incremented classnames when first choice is taken" do
    Card.generate_codename_for("User").should == "User1"
  end
end                  

describe Card, "created without permission" do
  before do
    User.as :anonymous
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
    Card.class_for('basic').should == Card::Basic
    Card.class_for('Cardtype').should == Card::Cardtype
  end
  
  it "should return nil for invalid type" do
    Card.class_for("mumbo-jumbo").should be_nil
    Card.class_for('$d_foo#adfa').should be_nil
  end
 
end


describe Card, "Card changed to become a Cardtype" do
  before do
    User.as :wagbot 
    @a = Card['a']
    @a.type = 'Cardtype'
    @a.save!
  end
  it "should have a create permission set" do
    Card['a'].who_can(:create).should_not == nil
  end
end

describe Card, "Normal card with junctions" do
  before do
    User.as :wagbot 
    @a = Card['a']
  end
  it "should confirm that it has junctions" do
    @a.junctions.length.should > 0
  end
  it "should successfull have its type changed" do
    @a.type = 'Number'; @a.save!
    Card['a'].type.should== 'Number'
  end
  it "should still have its junctions after changing type" do
    @a.type = 'CardtypeE'; @a.save!
    Card['a'].junctions.length.should > 0
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
    @card.type='Cardtype'
    @card.save!
    
  end
  it "should successfully change its type to a Cardtype" do
    Card['convertible'].type.should=='Cardtype'
  end
  it "should have an extension" do
    Card['convertible'].extension.should_not== nil
  end
end



describe User, "Joe User" do
  before do
    User.as :wagbot 
    @r3 = Role[:r3]
    @ctf_t = Card.create! :name=>'Cardtype F+*tform'
    @ctf_t.permit(:create, @r3)
    @ctf_t.save!

    User.as :joe_user
    @user = User[:joe_user]
    @ctf = Card['Cardtype F']
    Cardtype.reset_cache
    @cardtype_names = Cardtype.createable_cardtypes.map{ |ct| ct[:name] }
  end

  it "should not have r3 permissions" do
    @user.roles.member?(@r3).should_not be_true
  end
  it "should ponder creating a card of Cardtype F, but find that he lacks create permissions" do
    @ctf.ok?(:create).should_not be_true
  end
  it "should not find Cardtype F on its list of createable cardtypes" do
    @cardtype_names.member?('Cardtype F').should_not be_true
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
    ctg.type = 'Basic'
    ctg.save!
    ctg = Card["CardtypeG"]
    ctg.type.should == 'Basic'
    ctg.extension.should == nil
  end
end


