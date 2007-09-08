require File.dirname(__FILE__) + '/../../spec_helper'
   

describe Card, "with soft tag template" do
  before do 
    User.as :admin do
      @bt = Card.create! :name=>"birthday+*template", :extension_type=>'SoftTemplate', 
              :type=>'Date', :content=>"Today!"
      @bt.permit(:comment, Role['auth']);  @bt.permit(:delete, Role['admin'])
      @bt.save!
    end
    User.as :joe_user
    @jb = Card.create! :name=>"Jim+birthday"
  end
  
  it "should have default cardtype" do
    @jb.type.should == 'Date'
  end
  
  it "should have default content" do
    Card['Jim+birthday'].content.should == 'Today!'
  end
  
  it "should have default permissions" do
    @jb.permissions.plot(:party).should == @bt.permissions.plot(:party)
  end
end


describe Card, "with hard tag template" do
  before do
    User.as :joe_user
    @bt = Card.create! :name=>"birthday+*template", :extension_type=>'HardTemplate',
      :type=>'Date', :content=>"Today!"
    @jb =  Card.create! :name=>"Jim+birthday"
  end       


  it "should change cardtype with template" do
    @bt.type = 'Basic'; @bt.save!
    Card['Jim+birthday'].type.should == 'Basic'
  end    


  it "should have default cardtype" do
    @jb.type.should == 'Date'
  end
  it "should have default content" do
    @jb.content.should == 'Today!'
  end        
  
  it "should change content with template" do
    @bt.content = "Tomorrow"; @bt.save!
    Card['Jim+birthday'].content.should == 'Tomorrow'
  end 
  
  it "should not let you change the type" do
    @jb.type = 'Basic'
    @jb.save.should_not be_true
    @jb.errors.on(:type).should_not be_nil
  end

     
end


describe Card, "with soft type template" do
  
end

describe Card, "with hard type template and hard tag template" do
  before do
    User.as :joe_user
    @bt = Card.create! :name=>"birthday+*template", :extension_type=>'HardTemplate',
      :type=>'Date', :content=>"Today!"      
    @dt = Card.create! :name=>"Date+*template", :extension_type=>'HardTemplate', :type=>'Date', :content=>'Tomorrow'
    @jb =  Card.create! :name=>"Jim+birthday"
  end       
  
  it "should have cardtype content" do
    @jb.content.should == 'Tomorrow'
  end
  
  it "should change content with cardtype" do
    @dt.content = 'Yesterday'; @dt.save!
    Card['Jim+birthday'].content.should== 'Yesterday'
  end
  
end
