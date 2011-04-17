require File.dirname(__FILE__) + '/../../spec_helper'
  
describe Card do
  describe "test data" do
    it "should be findable by name" do
      Card.find_by_name("Wagn Bot").class.should == Card::Basic
    end
  end

  describe  "new" do
    context "with name" do
      before do
        @c = Card.new :name=>"Ceee"
        @d = Card::Date.new
      end
  
      it "c should have name before_typecast" do
        @c.name_before_type_cast.should == "Ceee"
      end
  
      it "c should have cardtype basic" do
        @c.type.should == 'Basic'
      end
  
      it "d should have cardtype Date" do
        @d.type.should == 'Date'
      end
    end

    context "plus card" do
      it "should have permissions" do
        User.as :wagbot
        Card.create :name=>"jill+pretty"
        Card['pretty'].permissions.should_not be_empty
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

  describe "#fetch_or_new" do
    context "when card not found" do
      it "new should have permissions" do
        c=Card.fetch_or_new "Bilboa"
        c.permissions.should_not be_empty
      end
    end
  end


  describe "attribute tracking for new card" do
    before(:each) do
      User.as :wagbot 
      @c = Card::Basic.new :name=>"New Card", :content=>"Great Content"
    end
  
    it "should have updates" do
      Cardlib::AttributeTracking::Updates.should === @c.updates
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


  describe ".create_or_update" do
    before do
      User.current_user = :wagbot
    end
      
    it "creates cards that aren't there" do
      Card.create_or_update :name => "nickelbock", :content => "boo"
      Card["nickelbock"].content.should == "boo"
    end

    it "updates cards that are there" do
      Card.create_or_update :name => "A", :content => "boo"
      Card["A"].content.should == "boo"
    end

    it "doesn't update cards if there aren't any diffs" do
      lambda {
        Card.create_or_update :name => "A+B", :content => "AlphaBeta"
      }.should_not change( Card["A+B"], :updated_at )
    end
  end
  
  describe ".save_all" do
    before { User.as(:wagbot) }
    
    it "creates plus cards" do
      Card.save_all({
        :name => "G",
        "+H" => "hubba"
      })
      Card["G+H"].content.should == "hubba"
    end
    
    it "creates pointer card" do
      Card.save_all({
        :name => "G",
        "+H" => ['abbra','cadaver']
      })
      Card["G+H"].content.should == "[[abbra]]\n[[cadaver]]"
    end
    
    it "created plus cards with the right type" do
      Card.save_all({
        :name => "G",
        "+H" => { :type => "Phrase", :content=>"boo" }
      })
      Card["G+H"].content.should == "boo"
      Card["G+H"].type.should == "Phrase"
    end
  end
end

