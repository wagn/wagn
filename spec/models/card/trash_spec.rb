require File.dirname(__FILE__) + '/../../spec_helper'


describe Card, "rename to trashed name" do
  before do
    User.as :admin
    @a = Card.find_by_name("A")
    @b = Card.find_by_name("B")
    @a.destroy!  #trash
    @b.update_attributes! :name=>"A"
  end
  
  it "should rename b to a" do
    @b.name.should == 'A'
  end
  
  it "should rename a to a*trash" do
    @a.reload.name.should == 'A*trash'
  end
end


describe Card, "sending to trash" do
  before do
    User.as :admin
    @c = Card.find_by_name("basicname")
    @c.destroy!
  end
  
  it "should be trash" do
    @c.trash.should == true
  end
  
  it "should not be findable by name" do
    Card.find_by_name("basicname").should == nil
  end                                           
  
  it "should still have revision" do
    @c.revisions.length.should == 1
    @c.current_revision.content.should == 'basiccontent'
  end
end


describe Card, "revival from trash" do
  before do
    User.as :admin
    Card.find_by_name("basicname").destroy!
    @c = Card.create! :name=>'basicname', :content=>'revived content'
  end
  
  it "should not be trash" do
    @c.trash.should == false
  end
  
  it "should have 2 revisions" do
    @c.revisions.length.should == 2
  end
  
  it "should still have old revisions" do
    @c.revisions[0].content.should == 'basiccontent'
  end
  
  it "should have a new revision" do
    @c.content.should == 'revived content'
  end
end


describe Card, "junction revival" do
  before do
    User.as :admin
    @c = Card.create! :name=>"basicname+woot", :content=>"basiccontent"
    @c.destroy!
    @c = Card.create! :name=>"basicname+woot", :content=>"revived content"
  end
     
  it "should not be trash" do
    @c.trash.should == false
  end
  
  it "should have 2 revisions" do
    @c.revisions.length.should == 2
  end
  
  it "should still have old revisions" do
    @c.revisions[0].content.should == 'basiccontent'
  end
  
  it "should have a new revision" do
    @c.content.should == 'revived content'
  end
end 
 