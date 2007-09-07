require File.dirname(__FILE__) + '/../../spec_helper'

=begin                                                
describe Card, "with soft tag template" do
  before do 
    User.as :admin do
      @bt = Card.create! :name=>"birthday+*template", :extension_type=>'SoftTemplate', 
              :type=>'Date', :content=>"Today!"
      @bt.permit(:comment, Role['auth']);  @bt.permit(:destroy, Role['admin'])
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
=end

describe Card, "with hard tag template" do
  before do
    User.as :joe_user
    @bt = Card.create! :name=>"birthday+*template", :extension_type=>'HardTemplate',
      :type=>'Date', :content=>"Today!"
    @jb =  Card.create! :name=>"Jim+birthday"
  end  
  it "should have default cardtype" do
    @jb.type.should == 'Date'
  end
  it "should have default content" do
    @jb.content.should == 'Today!'
  end        

  
  it "should change content with template" do
    puts "READER0 " + @jb.who_can(:read).to_s
    puts "READER1 " + Card['Jim+birthday'].who_can(:read).to_s
    @bt.content = "Tomorrow"; @bt.save!
    puts "READER2 " + Card['Jim+birthday'].who_can(:read).to_s
    Card['Jim+birthday'].content.should == 'Tomorrow'
  end

  it "should change cardtype with template" do
    @bt.type = 'Basic'; @bt.save!
    Card['Jim+birthday'].type.should == 'Basic'
  end    

end