require_relative '../../../spec_helper'

describe Card do
  describe ".fetch" do
    it "returns and caches existing cards" do
      Card.fetch("A").should be_instance_of(Card)
      Card.cache.read("a").should be_instance_of(Card)
      Card.should_not_receive(:find_by_key)
      Card.fetch("A").should be_instance_of(Card)
    end

    it "returns nil and caches missing cards" do
      Card.fetch("Zork").should be_nil
      Card.cache.read("zork").missing.should be_true
      Card.fetch("Zork").should be_nil
    end

    it "returns nil and caches trash cards" do
      User.as(:wagbot)
      Card.fetch("A").destroy!
      Card.fetch("A").should be_nil
      Card.should_not_receive(:find_by_key)
      Card.fetch("A").should be_nil
    end

    it "returns and caches builtin cards" do
      Card.fetch("*head").should be_instance_of(Card)
      Card.cache.read("*head").should_not be_nil
    end

    it "returns virtual cards and caches them as missing" do
      User.as(:wagbot)
      card = Card.fetch("Joe User+*email")
      card.should be_instance_of(Card)
      card.name.should == "Joe User+*email"
      card.content.should == 'joe@user.com'
      cached_card = Card.cache.read("joe_user+*email")
      cached_card.missing?.should be_true
      cached_card.virtual?.should be_true
    end

    it "does not recurse infinitely on template templates" do
      Card.fetch("*content+*right+*content").should be_nil
    end

    it "expires card and dependencies on save" do
      #Card.cache.dump # should be empty
      Card.cache.reset_local
      Card.cache.local.keys.should == []

      User.as :wagbot

      a = Card.fetch("A")
      a.should be_instance_of(Card)

      # expires the saved card
      Card.cache.should_receive(:delete).with('a')

      # expires plus cards
      Card.cache.should_receive(:delete).with('c+a')
      Card.cache.should_receive(:delete).with('d+a')
      Card.cache.should_receive(:delete).with('f+a')
      Card.cache.should_receive(:delete).with('a+b')
      Card.cache.should_receive(:delete).with('a+c')
      Card.cache.should_receive(:delete).with('a+d')
      Card.cache.should_receive(:delete).with('a+e')
      Card.cache.should_receive(:delete).with('a+b+c')

      # expired including? cards
      Card.cache.should_receive(:delete).with('x').twice
      Card.cache.should_receive(:delete).with('y').twice
      a.save!
    end

    describe "preferences" do
      before do
        User.as :wagbot
      end

      it "prefers db cards to pattern virtual cards" do
        Card.create!(:name => "y+*right+*content", :content => "Formatted Content")
        Card.create!(:name => "a+y", :content => "DB Content")
        card = Card.fetch("a+y")
        card.virtual?.should be_false
        card.content.should == "DB Content"
        card.setting('content').should == "Formatted Content"
      end

      it "prefers a pattern virtual card to trash cards" do
        Card.create!(:name => "y+*right+*content", :content => "Formatted Content")
        Card.create!(:name => "a+y", :content => "DB Content")
        Card.fetch("a+y").destroy!

        card = Card.fetch("a+y")
        card.virtual?.should be_true
        card.content.should == "Formatted Content"
      end

      it "should recognize pattern overrides" do
        Card.create!(:name => "y+*right+*content", :content => "Right Content")
        card = Card.fetch("a+y")
        card.virtual?.should be_true
        card.content.should == "Right Content"
        tpr = Card.create!(:name => "Basic+y+*type plus right+*content", :content => "Type Plus Right Content")
        card = Card.fetch("a+y")
        card.virtual?.should be_true
        card.content.should == "Type Plus Right Content"
        tpr.destroy!
        card = Card.fetch("a+y")
        card.virtual?.should be_true
        card.content.should == "Right Content"
        
      end

      it "should not hit the database for every fetch_virtual lookup" do
        Card.create!(:name => "y+*right+*content", :content => "Formatted Content")
        Card.fetch("a+y")
        Card.should_not_receive(:find_by_key)
        Card.fetch("a+y")
      end
      
      it "should not be a new_record after being saved" do
        Card.create!(:name=>'growing up')
        card = Card.fetch('growing up')
        card.new_record?.should be_false
      end
    end
  end

  describe "#fetch_or_new" do
    it "returns a new card if it doesn't find one" do
      new_card = Card.fetch_or_new("Never Seen Me Before")
      new_card.should be_instance_of(Card)
      new_card.new_record?.should be_true
    end

    it "returns a card if it finds one" do
      new_card = Card.fetch_or_new("A+B")
      new_card.should be_instance_of(Card)
      new_card.new_record?.should be_false
    end

    it "takes a second hash of options as new card options" do
      new_card = Card.fetch_or_new("Never Before", :type => "Image")
      new_card.should be_instance_of(Card)
      new_card.typecode.should == 'Image'
      new_card.new_record?.should be_true
    end
  end

  describe "#fetch_virtual" do
    before { User.as :joe_user }

    it "should find cards with *right+*content specified" do
      User.as :wagbot do
        Card.create! :name=>"testsearch+*right+*content", :content=>'{"plus":"_self"}', :type => 'Search'
      end
      c = Card.fetch_virtual("A+testsearch")
      c.typecode.should == 'Search'
      c.content.should ==  "{\"plus\":\"_self\"}"
    end
  end

  describe "#exists?" do
    it "is true for cards that are there" do
      Card.exists?("A").should == true
    end

    it "is false for cards that arent'" do
      Card.exists?("Mumblefunk is gone").should == false
    end
  end
end
