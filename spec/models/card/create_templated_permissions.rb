require File.dirname(__FILE__) + '/../../spec_helper'

describe Card, "New Basic Card" do
  before do
    User.as :wagbot 
    @bt= Card['Basic+*type+*default']
    @r1 = Role.find_by_codename 'r1'
    @bt.permit(:edit, @r1)
    @bt.save!
    User.as :joe_user
    @bc = Card.create! :name=> 'Plain Jane'
  end
  
  it "should have r1 edit permissions because its template is set to that" do
    @bc.who_can(:edit).should==@r1
  end   
  
  it "should not have create permissions assigned directly to the card itself" do
    @bc.who_can(:create).should== nil
  end
end

     
describe Card, "Cardtype template" do
  before do
    User.as :wagbot 
    @ctt = Card['Cardtype E+*type+*default']
    @r1 = Role.find_by_codename 'r1'
    @ctt.permit(:create, @r1)
    #warn "permissions #{@ctt.permissions.plot :task}"
    @ctt.save!
    @ct = Card.find_by_name 'Cardtype E'
  end
  it "should update the template's create permission when a create permission is submitted" do
    @ctt.who_can(:create).should== @r1
  end
  it "should update the cardtype's create permission when a create permission is submitted" do
    @ct.who_can(:create).should== @r1
  end
  it "should not overwrite the cardtype's other permissions" do
    @ct.permissions.length.should == 4
  end
end
   

describe Card, "Cardtype template" do
  before do
    User.as :wagbot 
    @ctt = Card['Cardtype E+*type+*default']
    @r1 = Role.find_by_codename 'r1'
    @ctt.permit(:create, @r1)
    #warn "permissions #{@ctt.permissions.plot :task}"
    @ctt.save!
    @ct = Card.find_by_name 'Cardtype E'
  end
  it "should update the template's create permission when a create permission is submitted" do
    @ctt.who_can(:create).should== @r1
  end
  it "should update the cardtype's create permission when a create permission is submitted" do
    @ct.who_can(:create).should== @r1
  end
  it "should not overwrite the cardtype's other permissions" do
    # this used to say 5.  but comment permissions are not required now-- it looks
    # those are the ones it doesn't have.  create;delete,read,edit are all there.
    @ct.permissions.length.should == 4
  end
end         

describe Card, "Basic Card template" do
  context "when a create permission is submitted" do 
    before do
      User.as :wagbot 
      @bt = Card.find_by_name 'Basic+*tform'
      @r1 = Role.find_by_codename 'r1'
      @bt.permit(:create, @r1)
      @bt.save!
      @b = Card.find_by_name 'Basic'
      @ctd = Card.find_by_name 'Cardtype D'
      @cte = Card.find_by_name 'Cardtype E'
    end

    it "should update the basic template's create permission" do
      @bt.who_can(:create).should== @r1
    end
    it "should update the basic cardtype's create permission" do
      @b.who_can(:create).should== @r1
    end
    
    it "should update other cardtypes' permissions" do
      @ctd.who_can(:create).should== @r1
    end
    
    it "should not update other cardtypes' permissions if they have a template set" do
      @cte.who_can(:create).should_not== @r1
    end  
  
    it "should keep create permission from template when updated directly" do
      @ctd.permissions = %w{read edit delete comment}.collect {|t| 
        Permission.new(:task=>t, :party=>::Role[:auth])
      }
      @ctd.save!
      @ctd.who_can(:create).should== @r1
    end
  end
end
