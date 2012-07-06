require File.expand_path('../../../spec_helper', File.dirname(__FILE__))

describe Card do
  context 'when there is a general toc setting of 2' do
     
    before do
      (@c1 = Card['Onne Heading']).should be
      (@c2 = Card['Twwo Heading']).should be
      (@c3 = Card['Three Heading']).should be
      @c1.typecode.should == 'Basic'
      (@rule_card = @c1.rule_card(:table_of_contents)).should be
    end

    describe ".rule" do
      it "should have a value of 2" do
        @rule_card.content.should == "2"
        @c1.rule(:table_of_contents).should == "2"
      end
    end

    describe "renders with/without toc" do
      it "should not render for 'Onne Heading'" do
        Wagn::Renderer.new(@c1).render.should_not match /Table of Contents/
      end
      it "should render for 'Twwo Heading'" do
        Wagn::Renderer.new(@c2).render.should match /Table of Contents/
      end
      it "should render for 'Three Heading'" do
        Wagn::Renderer.new(@c3).render.should match /Table of Contents/
      end
    end

    describe ".rule_card" do
      it "get the same card without the * and singular" do
        @c1.rule_card(:table_of_contents).should == @rule_card
      end
    end

    describe ".related_sets" do
      it "should have 2 sets (self and right) for a simple card" do
        sets = Card['A'].related_sets
        sets.should ==  ["A+*self", "A+*right"]
      end
      it "should have 3 sets (self, type, and right) for a cardtype card" do
        sets = Card['Cardtype A'].related_sets
        sets.should == ["Cardtype A+*self", "Cardtype A+*type", "Cardtype A+*right"] 
      end
      it "should only be self for plus cards" do
        sets = Card['A+B'].related_sets
        sets.should ==  ["A+B+*self"]
      end
      it "should include exising type plus right sets of which a card is on the right" do
        Card.create :name=>'Cardtype A+B+*type plus right', :content=>''
        sets = Card['B'].related_sets
        sets.should == ["B+*self", "B+*right", 'Cardtype A+B+*type plus right']
      end
    end

    # class methods
    describe ".default_rule" do
      it 'should have default rule' do
        Card.default_rule(:table_of_contents).should == '0'
      end
    end

    describe ".default_rule_card" do
    end

    describe ".universal_setting_names_by_group" do
    end
  end

  before do
    User.as(:wagbot)
  end
  
  describe "setting data setup" do
    it "should make Set of +*type" do
      Card.create! :name=>"SpeciForm", :type=>'Cardtype'
      Card.create!( :name=>"SpeciForm+*type" ).typecode.should == "Set"
    end
  end

  describe "#settings" do
    it "retrieves Set based value" do
      Card.create :name => "Book+*type+*add help", :content => "authorize"
      Card.new( :type => "Book" ).rule('add help', 'edit help').should == "authorize"
    end                                          
    
    it "retrieves default values" do
      Card.create :name => "all Basic cards", :type => "Set", :content => "{\"type\": \"Basic\"}"  #defaults should work when other Sets are present
      assert c=Card.create(:name => "*all+*add help", :content => "lobotomize")
      Card.default_rule('add help', 'edit help').should == "lobotomize"
      Card.new( :type => "Basic" ).rule('add help', 'edit help').should == "lobotomize"
    end                                                                 
    
    it "retrieves single values" do
      Card.create! :name => "banana+*self+*edit help", :content => "pebbles"
      Card["banana"].rule('edit help').should == "pebbles"
    end
  end
  
  
  context "cascading settings" do
    before do
      Card.create :name => "*all+*edit help", :content => "edit any kind of card"
    end
    
    it "retrieves default setting" do
      Card.new( :type => "Book" ).rule('add help', 'edit help').should == "edit any kind of card"
    end
    
    it "retrieves primary setting" do
      Card.create :name => "*all+*add help", :content => "add any kind of card"
      Card.new( :type => "Book" ).rule('add help', 'edit help').should == "add any kind of card"
    end
    
    it "retrieves more specific default setting" do
      Card.create :name => "*all+*add help", :content => "add any kind of card"
      Card.create :name => "*Book+*type+*edit help", :content => "edit a Book"
      Card.new( :type => "Book" ).rule('add help', 'edit help').should == "add any kind of card"
    end
  end

  describe "#setting_names" do
    before do
      @pointer_settings = ['*options','*options label','*input']
    end
    it "returns universal setting names for non-pointer set" do
      snbg = Card.fetch('*star').setting_names_by_group
      snbg.keys.length.should == 4
      snbg.keys.member?( :pointer ).should_not be_true
    end
    
    it "returns pointer-specific setting names for pointer card (*type)" do
      # was this test wrong before?  What made Fruit a pointer without this?
      User.as :wagbot do
        Rails.logger.info "testing point 0"
        c1=Card.create! :name=>'Fruit+*type+*default', :type=>'Pointer'
        Rails.logger.info "testing point 1 #{c1.inspect}"
      end
      c2 = Card.fetch('Fruit+*type')
      Rails.logger.info "testing point 2 #{c2.inspect}"
      snbg = c2.setting_names_by_group
      snbg[:pointer].map(&:to_s).should == @pointer_settings
      c3 = Card.fetch('Pointer+*type')
      Rails.logger.info "testing point 3 #{c3.inspect}"
      snbg = c3.setting_names_by_group
      snbg[:pointer].map(&:to_s).should == @pointer_settings
    end

    it "returns pointer-specific setting names for pointer card (*self)" do
      snbg = Card.fetch_or_new('*account+*related+*self').setting_names_by_group
      snbg[:pointer].map(&:to_s).should == @pointer_settings
    end

  end
  
  describe "#item_names" do
    it "returns item for each line of basic content" do
      Card.new( :name=>"foo", :content => "X\nY" ).item_names.should == ["X","Y"]
    end

    it "returns list of card names for search" do
      c = Card.new( :name=>"foo", :type=>"Search", :content => %[{"name":"Z"}])
      c.item_names.should == ["Z"]
    end
    
    it "handles searches relative to context card" do
      # note: A refers to 'Z'
      c = Card.new :name=>"foo", :type=>"Search", :content => %[{"referred_to_by":"_self"}]
      c.item_names( :context=>'A' ).should == ["Z"]
    end
  end
  
  describe "#extended_list" do
    it "returns item's content for pointer setting" do
      c = Card.new(:name=>"foo", :type=>"Pointer", :content => "[[Z]]")
      c.extended_list.should == ["I'm here to be referenced to"]
    end
  end
  
  describe "#contextual_content" do
    it "returns content for basic setting" do
      Card.new(:name=>"foo", :content => "X").contextual_content.should == "X"
    end
    
    it "processes inclusions relative to context card" do
      context_card = Card["A"] # refers to 'Z'
      c = Card.new(:name=>"foo", :content => "{{_self+B|core}}")
      c.contextual_content( context_card ).should == "AlphaBeta"
    end
    
    it "returns content even when context card is hard templated" do
      context_card = Card["A"] # refers to 'Z'
      c1=Card.create! :name => "A+*self+*content", :content => "Banana"
      c = Card.new( :name => "foo", :content => "{{_self+B|core}}" )
      c.contextual_content( context_card ).should == "AlphaBeta"
    end
  end
end
