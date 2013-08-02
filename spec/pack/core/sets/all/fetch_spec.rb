# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card do
  describe ".fetch" do
    it "returns and caches existing cards" do
      Card.fetch("A").should be_instance_of(Card)
      Card.cache.read("a").should be_instance_of(Card)
      mock.dont_allow(Card).find_by_key
      Card.fetch("A").should be_instance_of(Card)
    end

    it "returns nil and caches missing cards" do
      Card.fetch("Zork").should be_nil
      Card.cache.read("zork").new_card?.should be_true
      Card.fetch("Zork").should be_nil
    end

    it "returns nil and caches trash cards" do
      Account.as_bot do
        Card.fetch("A").delete!
        Card.fetch("A").should be_nil
        mock.dont_allow(Card).find_by_key
        Card.fetch("A").should be_nil
      end
    end

    it "returns and caches builtin cards" do
      Card.fetch("*head").should be_instance_of(Card)
      Card.cache.read("*head").should_not be_nil
    end

    it "returns virtual cards and caches them as missing" do
      Account.as_bot do
        card = Card.fetch("Joe User+*email")
        card.should be_instance_of(Card)
        card.name.should == "Joe User+*email"
        Card::Format.new(card).render_raw.should == 'joe@user.com'
      end
      #card.raw_content.should == 'joe@user.com'
      #cached_card = Card.cache.read("joe_user+*email")
      #cached_card.missing?.should be_true
      #cached_card.virtual?.should be_true
    end

    it "fetches virtual cards after skipping them" do
      Card['A+*self'].should be_nil
      Card.fetch( 'A+*self' ).should_not be_nil
    end
    

    it "fetches newly virtual cards" do
      #pending "needs new cache clearing"
      Card.fetch( 'A+virtual').should be_nil
      Account.as_bot { Card.create :name=>'virtual+*right+*structure' }
      Card.fetch( 'A+virtual').should_not be_nil
    end
    
    it "handles name variants of cached cards" do
      Card.fetch('yomama+*self').name.should == 'yomama+*self'
      Card.fetch('YOMAMA+*self').name.should == 'YOMAMA+*self'
      Card.fetch('yomama', :new=>{}).name.should == 'yomama'
      Card.fetch('YOMAMA', :new=>{}).name.should == 'YOMAMA'
      Card.fetch('yomama!', :new=>{ :name=>'Yomama'} ).name.should == 'Yomama'
#      Card.fetch('yomama!', :new=>{ :type=>'Phrase'} ).name.should == 'yomama!'  FIXME!!     
    end

    it "does not recurse infinitely on template templates" do
      Card.fetch("*structure+*right+*structure").should be_nil
    end

    it "expires card and dependencies on save" do
      #Card.cache.dump # should be empty
      Card.cache.reset_local
      Card.cache.local.keys.should == []

      Account.as_bot do

        a = Card.fetch("A")
        a.should be_instance_of(Card)

        # expires the saved card
        mock(Card.cache).delete('a')
        mock(Card.cache).delete(/~\d+/).at_least(12)

        # expires plus cards
        mock(Card.cache).delete('c+a')
        mock(Card.cache).delete('d+a')
        mock(Card.cache).delete('f+a')
        mock(Card.cache).delete('a+b')
        mock(Card.cache).delete('a+c')
        mock(Card.cache).delete('a+d')
        mock(Card.cache).delete('a+e')
        mock(Card.cache).delete('a+b+c')

        # expired including? cards
        mock(Card.cache).delete('x').times(2)
        mock(Card.cache).delete('y').times(2)
        a.save!
      end
    end

    describe "preferences" do
      before do
        Account.as(Card::WagnBotID) # FIXME: as without a block is deprecated
      end

      it "prefers db cards to pattern virtual cards" do
        c1=Card.create!(:name => "y+*right+*structure", :content => "Formatted Content")
        c2=Card.create!(:name => "a+y", :content => "DB Content")
        card = Card.fetch("a+y")
        card.virtual?.should be_false
        card.rule(:structure).should == "Formatted Content"
        card.content.should == "DB Content"
      end

      it "prefers a pattern virtual card to trash cards" do
        Card.create!(:name => "y+*right+*structure", :content => "Formatted Content")
        Card.create!(:name => "a+y", :content => "DB Content")
        Card.fetch("a+y").delete!

        card = Card.fetch("a+y")
        card.virtual?.should be_true
        card.content.should == "Formatted Content"
      end

      it "should recognize pattern overrides" do
        #~~~ create right rule
        tc=Card.create!(:name => "y+*right+*structure", :content => "Right Content")
        card = Card.fetch("a+y")
        card.virtual?.should be_true
        card.content.should == "Right Content"
        
#        warn "creating template"
        tpr = Card.create!(:name => "Basic+y+*type plus right+*structure", :content => "Type Plus Right Content")
        card = Card.fetch("a+y")
        card.virtual?.should be_true
        card.content.should == "Type Plus Right Content"

        #~~~ delete type plus right rule
        tpr.delete!
        card = Card.fetch("a+y")
        card.virtual?.should be_true
        card.content.should == "Right Content"

      end

      it "should not hit the database for every fetch_virtual lookup" do
        Card.create!(:name => "y+*right+*structure", :content => "Formatted Content")
        Card.fetch("a+y")
        mock.dont_allow(Card).find_by_key
        Card.fetch("a+y")
      end

      it "should not be a new_record after being saved" do
        Card.create!(:name=>'growing up')
        card = Card.fetch('growing up')
        card.new_record?.should be_false
      end
    end
  end

  describe "#fetch :new=>{ ... }" do
    it "returns a new card if it doesn't find one" do
      new_card = Card.fetch "Never Seen Me Before", :new=>{}
      new_card.should be_instance_of(Card)
      new_card.new_record?.should be_true
    end

    it "returns a card if it finds one" do
      new_card = Card.fetch "A+B", :new=>{}
      new_card.should be_instance_of(Card)
      new_card.new_record?.should be_false
    end

    it "takes a second hash of options as new card options" do
      new_card = Card.fetch "Never Before", :new=>{ :type => "Image" }
      new_card.should be_instance_of(Card)
      new_card.typecode.should == :image
      new_card.new_record?.should be_true
      Card.fetch( 'Never Before', :new=>{} ).type_id.should == Card::BasicID
    end
  end

  describe "#fetch_virtual" do
    it "should find cards with *right+*structure specified" do
      Account.as_bot do
        Card.create! :name=>"testsearch+*right+*structure", :content=>'{"plus":"_self"}', :type => 'Search'
      end
      c = Card.fetch("A+testsearch".to_name)
      assert c.virtual?
      c.typecode.should == :search_type
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
