require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe Card do
  context 'when there is a general toc setting of 2' do

    before do
      (@c1 = Card['Onne Heading']).should be
      (@c2 = Card['Twwo Heading']).should be
      (@c3 = Card['Three Heading']).should be
      @c1.type_id.should == Card::BasicID
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
        sets = Card['A'].related_sets.map { |s| s[0] }
        sets.should == ['A+*self', 'A+*right']
      end
      it "should have 3 sets (self, type, and right) for a cardtype card" do
        sets = Card['Cardtype A'].related_sets.map { |s| s[0] }
        sets.should == ['Cardtype A+*type', 'Cardtype A+*self', 'Cardtype A+*right']
      end
#      it "should show type plus right sets when they exist" do
#        Account.as_bot { Card.create :name=>'Basic+A+*type plus right', :content=>'' }
#        sets = Card['A'].related_sets
#        sets.should == ['A+*self', 'A+*right', 'Basic+A+*type plus right']
#      end
#      it "should show type plus right sets when they exist, and type" do
#        Account.as_bot { Card.create :name=>'Basic+Cardtype A+*type plus right', :content=>'' }
#        sets = Card['Cardtype A'].related_sets
#        sets.should == ['Cardtype A+*self', 'Cardtype A+*type', 'Cardtype A+*right', 'Basic+Cardtype A+*type plus right']
#      end
      it "should have sets for a non-simple card" do
        sets = Card['A+B'].related_sets.map { |s| s[0] }
        sets.should == ['A+B+*self']
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

    describe ".setting_attrib" do
    end

  end

  context "when I change the general toc setting to 1" do

    before do
      (@c1 = Card["Onne Heading"]).should be
      (@c2 = Card["Twwo Heading"]).should be
      @c1.type_id.should == Card::BasicID
      (@rule_card = @c1.rule_card(:table_of_contents)).should be
      @rule_card.content = "1"
    end

    describe ".rule" do
      it "should have a value of 1" do
        @rule_card.content.should == "1"
        @c1.rule(:table_of_contents).should == "1"
      end
    end

    describe "renders with/without toc" do
      it "should not render toc for 'Onne Heading'" do
        Wagn::Renderer.new(@c1).render.should match /Table of Contents/
      end
      it "should render toc for 'Twwo Heading'" do
        Wagn::Renderer.new(@c2).render.should match /Table of Contents/
      end
      it "should not render for 'Twwo Heading' when changed to 3" do
        @rule_card.content = "3"
        @c2.rule(:table_of_contents).should == "3"
        Wagn::Renderer.new(@c2).render.should_not match /Table of Contents/
      end
    end

  end

  context 'when I use CardtypeE cards' do

    before do
      Account.as_bot do
        @c1 = Card.create :name=>'toc1', :type=>"CardtypeE",
          :content=>Card['Onne Heading'].content
        @c2 = Card.create :name=>'toc2', :type=>"CardtypeE",
          :content=>Card['Twwo Heading'].content
        @c3 = Card.create :name=>'toc3', :type=>"CardtypeE",
          :content=>Card['Three Heading'].content
      end
      @c1.type_name.should == 'Cardtype E'
      @rule_card = @c1.rule_card(:table_of_contents)

      @c1.should be
      @c2.should be
      @c3.should be
      @rule_card.should be
    end

    describe ".rule" do
      it "should have a value of 0" do
        @c1.rule(:table_of_contents).should == "0"
        @rule_card.content.should == "0"
      end
    end

    describe "renders without toc" do
      it "should not render for 'Onne Heading'" do
        Wagn::Renderer.new(@c1).render.should_not match /Table of Contents/
      end
      it "should render for 'Twwo Heading'" do
        Wagn::Renderer.new(@c2).render.should_not match /Table of Contents/
      end
      it "should render for 'Three Heading'" do
        Wagn::Renderer.new(@c3).render.should_not match /Table of Contents/
      end
    end

    describe ".rule_card" do
      it "doesn't have a type rule" do
        @rule_card.should be
        @rule_card.name.should == "*all+*table of contents"
      end

      it "get the same card without the * and singular" do
        @c1.rule_card(:table_of_contents).should == @rule_card
      end
    end

    # class methods
    describe ".default_rule" do
      it 'should have default rule' do
        Card.default_rule(:table_of_contents).should == '0'
      end
    end

  end

  context "when I create a new rule" do
    before do
      Account.as_bot do
        @c1 = Card.create :name=>'toc1', :type=>"CardtypeE",
          :content=>Card['Onne Heading'].content
        # FIXME: CardtypeE should inherit from *default => Basic
        @c2 = Card.create :name=>'toc2', #:type=>"CardtypeE",
          :content=>Card['Twwo Heading'].content
        @c3 = Card.create :name=>'toc3', #:type=>"CardtypeE",
          :content=>Card['Three Heading'].content
        @c1.type_name.should == 'Cardtype E'
        @rule_card = @c1.rule_card(:table_of_contents)

        @c1.should be
        @c2.should be
        @c3.should be
        @rule_card.name.should == '*all+*table of contents'
        if c=Card['CardtypeE+*type+*table of content']
          c.content = '2'
          c.save!
        else
          c=Card.create! :name=>'CardtypeE+*type+*table of content', :content=>'2'
        end
      end
    end
    it "should take on new setting value" do
      c = Card['toc1']
      c.rule_card(:table_of_contents).name.should == 'CardtypeE+*type+*table of content'
      c.rule(:table_of_contents).should == "2"
    end

    describe "renders with/without toc" do
      it "should not render for 'Onne Heading'" do
        Wagn::Renderer.new(@c1).render.should_not match /Table of Contents/
      end
      it "should render for 'Twwo Heading'" do
        @c2.rule(:table_of_contents).should == "2"
        Wagn::Renderer.new(@c2).render.should match /Table of Contents/
      end
      it "should render for 'Three Heading'" do
        Wagn::Renderer.new(@c3).render.should match /Table of Contents/
      end
    end
  end
#end

  context "when I change the general toc setting to 1" do

    before do
      (@c1 = Card["Onne Heading"]).should be
      # FIXME: CardtypeE should inherit from *default => Basic
      #@c2 = Card.create :name=>'toc2', :type=>"CardtypeE", :content=>Card['Twwo Heading'].content
      (@c2 = Card["Twwo Heading"]).should be
      @c1.type_id.should == Card::BasicID
      (@rule_card = @c1.rule_card(:table_of_contents)).should be
      @rule_card.content = "1"
    end

    describe ".rule" do
      it "should have a value of 1" do
        @rule_card.content.should == "1"
        @c1.rule(:table_of_contents).should == "1"
      end
    end

    describe "renders with/without toc" do
      it "should not render toc for 'Onne Heading'" do
        Wagn::Renderer.new(@c1).render.should match /Table of Contents/
      end
      it "should render toc for 'Twwo Heading'" do
        Wagn::Renderer.new(@c2).render.should match /Table of Contents/
      end
      it "should not render for 'Twwo Heading' when changed to 3" do
        @rule_card.content = "3"
        Wagn::Renderer.new(@c2).render.should_not match /Table of Contents/
      end
    end

  end
end

