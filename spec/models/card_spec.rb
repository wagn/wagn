require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Card do
  context "new" do
    it "gracefully handles explicit nil as parameters" do
      Card.new( nil ).should be_instance_of(Card)
    end
    
    it "gracefully handles explicit nil name" do
      Card.new( :name => nil ).should be_instance_of(Card)
    end
  end
  
  describe "module inclusion" do
    before do
      Session.as :joe_user
      @c = Card.new :type=>'Search', :name=>'Module Inclusion Test Card'
    end
    
    it "gets needed methods after new" do
      @c.respond_to?( :get_spec ).should be_true
    end
    
    it "gets needed methods after save" do
      @c.save!
      @c.respond_to?( :get_spec ).should be_true
    end
    
#    it "gets needed methods after find" do
#      @c.save!
#      c = Card[@c.name]
#      c.respond_to?( :get_spec ).should be_true
#    end
    
    it "gets needed methods after fetch" do
      @c.save!
      c = Card.fetch(@c.name)
      c.respond_to?( :get_spec ).should be_true
    end
  end

  describe "pointer module inclusion" do
    before do
      @c_args = { :name=>'Home+*watchers' }
    end
    
    it "gets needed methods with explicit pointer setting" do
      Rails.logger.info "testing point"
      Card.new(@c_args.merge(:type=>'Pointer')).
               respond_to?(:add_item).should be_true
    end
    
    it "gets needed methods with implicit pointer setting (from template)" do
      c=Card.new(@c_args)
      Rails.logger.info "testing point #{c.inspect} N:#{c.name}"
      c.respond_to?(:add_item).should be_true
    end
  end

  
  describe "#create" do 
    it "calls :after_create hooks" do
      # We disabled these for the most part, what replaces them?
      #[:before_save, :before_create, :after_save, :after_create].each do |hookname|
      pending "mock rr seems to be broken, maybe 'call' collides with internal methode"
      mock(Wagn::Hook).call(:after_create, instance_of(Card))
      Session.as_bot do
        Card.create :name => "testit"
      end
    end
  end
  
  describe "test data" do
    it "should be findable by name" do
      Card["Wagn Bot"].class.should == Card
    end
  end

  describe  "new" do
    context "with name" do
      before do
        @c = Card.new :name=>"Ceee"
        @d = Card.new :type=>'Date'
      end
  
      it "c should have cardtype basic" do
        Rails.logger.info "testing point #{@c} #{@c.inspect}"
        @c.typecode.should == :basic
      end
  
      it "d should have cardtype Date" do
        Rails.logger.info "testing point #{@d} #{@d.inspect}"
        @d.typecode.should == :date
      end
    end

    it "name is not nil" do
      Card.new.name.should == ""
      Card.new( nil ).name.should == ""
    end
  end
                            
  describe "creation" do
    before(:each) do           
      Session.as_bot do
        @b = Card.create! :name=>"New Card", :content=>"Great Content"
        @c = Card.find(@b.id)
      end
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
      Card["New Card"].class.should == Card
    end  
  end


  describe "attribute tracking for new card" do
    before(:each) do
      Session.as_bot do
        @c = Card.new :name=>"New Card", :content=>"Great Content"
      end
    end
  
    it "should have updates" do
      Wagn::Model::AttributeTracking::Updates.should === @c.updates
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
      @c = Card["Joe User"]
    end
  end                    

  describe "content change should create new revision" do
    before do
      Session.as_bot do
        @c = Card['basicname']
        @c.update_attributes! :content=>'foo'
      end
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
      Session.as_bot do
        @c = Card['basicname']
        @c.content = "foo"
        @c.save!
      end
    end
  
    it "should have 2 revisions"  do
      @c.revisions.length.should == 2
    end
  
    it "should have original revision" do
      @c.revisions[0].content.should == 'basiccontent'
    end
  end    
     

  describe "created a virtual card when missing and has a template" do
    it "should be flagged as virtual" do
      Card.new(:name=>'A+*last edited').virtual?.should be_true
    end
  end
end

