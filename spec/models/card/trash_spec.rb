require File.dirname(__FILE__) + '/../../spec_helper'

# FIXME: these user tests should probably be in a set of cardtype specific tests somewhere..   
describe User, "with revisions" do
  before do User.as :admin; @c = Card.find_by_name("Admin"); end
  it "should not be removable" do
    @c.destroy.should_not be_true
  end
end

describe User, "without revisions" do
  before do User.as :admin; @c = Card.find_by_name("Sample User"); end
  it "should be removable" do
    @c.destroy!.should be_true
  end
end

describe Card, "connected to unremovable card" do
  before do
     User.as :admin                                    
     # this ugly setup makes it so A+Admin is the actual user with edits..
     Card["Admin"].update_attributes! :name=>"A+Admin"  
  end
  it "should not be removable" do
    @a = Card['A']
    @a.confirm_destroy = true
    @a.destroy.should_not be_true
  end
end
                 
describe Card, "dependent removal" do
  before do
    User.as :joe_user
    @a = Card['A']
    @a.destroy!
    @c = Card.find_by_key "A+B+C".to_key
  end

  it "should be trash" do
    @c.trash.should be_true
  end

  it "should not be findable by name" do
    Card.find_by_name("A+B+C").should == nil
  end                                           

  it "should still have permissions" do
    @c.permissions.should_not be_empty
  end

end
                       
describe Card, "rename to trashed name" do
  before do
    User.as :admin
    @a = Card.find_by_name("A")
    @b = Card.find_by_name("B")
    @a.destroy!  #trash
    @b.update_attributes! :name=>"A", :confirm_rename=>true
  end
  
  it "should rename b to a" do
    @b.name.should == 'A'
  end
  
  it "should rename a to a*trash" do
    @a.reload.name.should == 'A*trash'
  end
end


describe Card, "sent to trash" do
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
  
  it "should still have permissions" do
    @c.permissions.should_not be_empty
  end
end

describe Card, "revived from trash" do
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
         
# FIXME OH FIXME
# if a tightly restricted card "Foo" is trashed, then someone with lesser permissions tries to
# create "Foo" they'll get permission denied and it won't make ANY sense. We should probably rename
# the trashed card to free up the namespace and start from scratch.

# FIXME
# if you destroy a card "Foo" of Cardtype A, then create card "Foo" of cardtype Basic, it should
# create that basic card as long as you have permissions to create basic cards.