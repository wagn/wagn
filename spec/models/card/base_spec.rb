require File.dirname(__FILE__) + '/../../spec_helper'
  
describe Card do
  describe "test data" do
    it "should be findable by name" do
      Card.find_by_name("Wagn Bot").class.should == Card
    end
  end

  describe  "new" do
    context "with name" do
      before do
        @c = Card.new :name=>"Ceee"
        @d = Card.new :type=>'Date'
      end
  
      it "c should have name before_typecast" do
        @c.name_before_type_cast.should == "Ceee"
      end
  
      it "c should have cardtype basic" do
        @c.typecode.should == 'Basic'
      end
  
      it "d should have cardtype Date" do
        @d.typecode.should == 'Date'
      end
    end

    it "name is not nil" do
      Card.new.name.should == ""
      Card.new( nil ).name.should == ""
    end
  end
                            
  describe "creation" do
    before(:each) do           
      User.as :wagbot 
      @b = Card.create! :name=>"New Card", :content=>"Great Content"
      @c = Card.find(@b.id)
    end
  
    it "should not have errors"        do @b.errors.size.should == 0        end
    it "should have the right class"   do @c.class.should    == Card        end
    it "should have the right key"     do @c.key.should      == "new_card"  end
    it "should have the right name"    do @c.name.should     == "New Card"  end
    it "should have the right content" do @c.content.should  == "Great Content" end

    it "should have a revision with the right content" do
      @c.current_revision.content == "Great Content"
    end

    it "should be findable by name" do
      Card.find_by_name("New Card").class.should == Card
    end  
  end


  describe "attribute tracking for new card" do
    before(:each) do
      User.as :wagbot 
      @c = Card.new :name=>"New Card", :content=>"Great Content"
    end
  
    it "should have updates" do
      Wagn::Card::AttributeTracking::Updates.should === @c.updates
    end
  
    it "should return original value" do
      @c.name.should == 'New Card'
    end
  
    it "should track changes" do
      @c.name = 'Old Card'
      @c.name.should == 'Old Card'
    end
  end

  describe "attribute tracking for existing card" do
    before(:each) do
      @c = Card.find_by_name("Joe User")
    end
  end                    

  describe "content change should create new revision" do
    before do
      User.as :wagbot 
      @c = Card.find_by_name('basicname')
      @c.update_attributes! :content=>'foo'
    end
  
    it "should have 2 revisions"  do
      @c.revisions.length.should == 2
    end
  
    it "should have original revision" do
      @c.revisions[0].content.should == 'basiccontent'
    end
  end


  describe "content change should create new revision" do
    before do
      User.as :wagbot 
      @c = Card.find_by_name('basicname')
      @c.content = "foo"
      @c.save!
    end
  
    it "should have 2 revisions"  do
      @c.revisions.length.should == 2
    end
  
    it "should have original revision" do
      @c.revisions[0].content.should == 'basiccontent'
    end
  end    
     

  describe "created with :virtual=>'true'" do
    it "should be flagged as virtual" do
      Card.new(:virtual=>true).virtual?.should be_true
    end
  end
end

