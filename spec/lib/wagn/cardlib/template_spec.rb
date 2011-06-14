require File.dirname(__FILE__) + '/../../../spec_helper'
   

describe Card do
  before do 
    User.as :wagbot
  end
  
  describe "#hard_templatees" do
    it "for User+*type+*content should return all Users" do
      Card.create(:name=>'User+*type+*content').hard_templatees.map(&:name).sort.should == [
        "Joe Admin", "Joe Camel", "Joe User", "John", "No Count", "Sample User", "Sara", "u1", "u2", "u3"
      ]
    end
  end
  
  it "#content_template" do
    pending
  end
  
  it "#expire_templatee_references" do
    pending
  end
  
end


describe Card, "with right content template" do
  before do
    User.as :joe_user
    @bt = Card.create! :name=>"birthday+*right+*content", :type=>'Date', :content=>"Today!"
    @jb = Card.create! :name=>"Jim+birthday"
  end       
 
  it "should have default content" do
    Renderer.new(@jb).render(:raw).should == 'Today!'
  end        
  
  it "should change content with template" do
    @bt.content = "Tomorrow"; @bt.save!
    Renderer.new( Card['Jim+birthday']).render(:raw).should == 'Tomorrow'
  end 
end


describe Card, "with right default template" do
  before do 
    User.as :wagbot  do
      @bt = Card.create! :name=>"birthday+*right+*default", :type=>'Date', :content=>"Today!"
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
    [:read, :edit, :comment, :delete].each do |task| 
      @jb.who_can(task).should== @bt.who_can(task)
    end
  end
end

describe Card, "templating" do
  before do
    User.as :joe_user
    @dt = Card.create! :name=>"Date+*type+*content", :type=>'Basic', :content=>'Tomorrow'
    @bt = Card.create! :name=>"birthday+*right+*content", :type=>'Date', :content=>"Today!"      
    @jb =  Card.new :name=>"Jim+birthday"
  end       
  
  it "*right setting should override *type setting" do
    Renderer.new(@jb).render(:raw).should == 'Today!'
  end
end

describe Card, "with type content template" do
  before do
    User.as :joe_user
    @dt = Card.create! :name=>"Date+*type+*content", :type=>'Basic', :content=>'Tomorrow'
  end       
  
  it "should return templated content even if content is passed in" do
    Renderer.new(Card.new(:type=>'Date', :content=>'')).render(:raw).should == 'Tomorrow'
  end
end



