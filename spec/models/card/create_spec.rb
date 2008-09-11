require File.dirname(__FILE__) + '/../../spec_helper'

# FIXME this shouldn't be here

describe Cardtype, "create with codename" do
  before do
    User.as :joe_user
  end
  it "should create cardtype with codename" do
    Card::Cardtype.create!(:name=>"Foo Type", :codename=>"foo").type.should=='Cardtype'
  end
end            

describe Card, "create these" do
  it 'should create basic cards given name and content' do 
    Card.create_these "testing_name" => "testing_content" 
    Card["testing_name"].content.should == "testing_content"
  end

  it 'should return the cards it creates' do 
    c = Card.create_these "testing_name" => "testing_content" 
    c.first.content.should == "testing_content"
  end
  
  it 'should create cards of a given type' do
    Card.create_these "Cardtype:Footype" => "" 
    Card["Footype"].type.should == "Cardtype"
  end
end

=begin
describe Card, "sets permissions correctly by default" do
  before do
    User.as :joe_user
    #@defaults = [:read,:edit,:comment,:delete].map{|t| Permission.new(:task=>t.to_s, :party=>::Role.find_by_codename('auth'))}
    @c = Card.create! :name=>"temp card"
  end
  
  it "should set default permissions immediately upon creation" do
#    warn "PERMISSIONS: #{Card.template('temp card').inspect}"
#    warn "Basic template: #{Card['Basic+*tform'].inspect}"
    @c.permissions.length.should==3
  end
  
  it "should preserve permissions setting after reload" do
    Card.find_by_name('temp card').permissions.length.should==3
  end
end

describe Card, "attribute tracking for new card" do
  before(:each) do     
    User.as :admin
    @c = Card::Basic.new :name=>"New Card", :content=>"Great Content"
  end
  
  it "should have updates" do
    ActiveRecord::AttributeTracking::Updates.should === @c.updates
  end
  
  it "should return original value" do
    @c.name.should == 'New Card'
  end
  
  it "should track changes" do
    @c.name = 'Old Card'
    @c.name.should == 'Old Card'
  end
end

describe Card, "Cardtype template" do
  before do
    User.as :admin
    @ctt = Card.create! :name=> 'Cardtype E+*tform'
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


describe Card, "basic create" do
  before(:each) do
    User.as :admin
    @b = Card.create :name=>"New Card", :content=>"Great Content"
    @c = Card.find(@b.id)
  end

  it "should not have errors"        do @b.errors.size.should == 0        end
  it "should have the right class"   do @c.class.should    == Card::Basic end
  it "should have the right key"     do @c.key.should      == "new_card"  end
  it "should have the right name"    do @c.name.should     == "New Card"  end
  it "should have the right content" do @c.content.should  == "Great Content" end

  it "should have a revision with the right content" do
    @c.current_revision.content == "Great Content"
  end

  it "should be findable by name" do
    Card.find_by_name("New Card").class.should == Card::Basic
  end  
end

describe Card, "create junction" do
  before(:each) do
    User.as :joe_user
    @c = Card.create! :name=>"Peach+Pear", :content=>"juicy"
  end

  it "should not have errors" do
    @c.errors.size.should == 0
  end

  it "should create junction card" do
    Card.find_by_name("Peach+Pear").class.should == Card::Basic
  end

  it "should create trunk card" do
    Card.find_by_name("Peach").class.should == Card::Basic
  end

  it "should create tag card" do
    Card.find_by_name("Pear").class.should == Card::Basic
  end
end


describe Card, "normal user create permissions" do
  before do
    User.as :joe_user
  end
  it "should allow anyone signed in to create Basic Cards" do
    Card::Base.ok?(:create).should be_true
  end
end

describe Card, "anonymous create permissions" do
  before do
    User.as :anon
  end
  it "should not allow someone not signed in to create Basic Cards" do
    Card::Base.ok?(:create).should_not be_true
  end
end
        

        
describe Card, "Cardtype template" do
  before do
    User.as :admin
    @ctt = Card.create! :name=> 'Cardtype E+*tform'
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

=end               


describe Card, "Basic Card template" do
  before do
    User.as :admin
    Card.create! :name=> 'Cardtype E+*tform'
    @bt = Card.find_by_name 'Basic+*tform'
    @r1 = Role.find_by_codename 'r1'
    @bt.permit(:create, @r1)
    @bt.save!
    @b = Card.find_by_name 'Basic'
    @ctd = Card.find_by_name 'Cardtype D'
    @cte = Card.find_by_name 'Cardtype E'
  end
  
  it "should update the basic template's create permission when a create permission is submitted" do
    @bt.who_can(:create).should== @r1
  end
  it "should update the basic cardtype's create permission when a create permission is submitted" do
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

describe Card, "New Basic Card" do
  before do
    User.as :admin
    @bt= Card['Basic+*tform']
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

                       