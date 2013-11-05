# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card::Set::All::Templating do

  describe "#structurees" do
    it "for User+*type+*structure should return all Users" do
      Account.as_bot do
        c=Card.create(:name=>'User+*type+*structure')
        c.structuree_names.sort.should == [
          "Joe Admin", "Joe Camel", "Joe User", "John", "No Count", "Sample User", "Sara", "u1", "u2", "u3"
        ]
      end
    end
  end

  it "#expire_structuree_references" do
    #TESTME
  end


  describe "with right structure" do
    before do
      Account.as_bot do
        @bt = Card.create! :name=>"birthday+*right+*structure", :type=>'Date', :content=>"Today!"
      end
      @jb = Card.create! :name=>"Jim+birthday"
    end

    it "should have default content" do
      Card::Format.new(@jb)._render_raw.should == 'Today!'
    end

    it "should change type and content with template" do
      Account.as_bot do
        @bt.content = "Tomorrow"
        @bt.type = 'Phrase'
        @bt.save!
      end
      jb = @jb.refresh force=true
      Card::Format.new( jb ).render(:raw).should == 'Tomorrow'
      jb.type_id.should == Card::PhraseID    
    end
  
    it "should have type and content overridden by (new) type_plus_right set" do
      Account.as_bot do
        Card.create! :name=>'Basic+birthday+*type plus right+*structure', :type=>'PlainText', :content=>'Yesterday'
      end
      jb = @jb.refresh force=true
      jb.raw_content.should == 'Yesterday'
      jb.type_id.should == Card::PlainTextID
    end
  end


  describe "with right default" do
    before do
      Account.as_bot  do
        @bt = Card.create! :name=>"birthday+*right+*default", :type=>'Date', :content=>"Today!"
      end
      @jb = Card.create! :name=>"Jim+birthday"
    end

    it "should have default cardtype" do
      @jb.type_code.should == :date
    end

    it "should have default content" do
      Card['Jim+birthday'].content.should == 'Today!'
    end
  end

  describe "with type structure" do
    before do
      Account.as_bot do
        @dt = Card.create! :name=>"Date+*type+*structure", :type=>'Basic', :content=>'Tomorrow'
      end
    end
    
    it "should return templated content even if content is passed in" do
      Card::Format.new(Card.new(:type=>'Date', :content=>''))._render(:raw).should == 'Tomorrow'
    end
    
    describe 'and right structure' do
      before do
        Account.as_bot do
          Card.create :name=>"Jim+birthday", :content=>'Yesterday'
          @bt = Card.create! :name=>"birthday+*right+*structure", :type=>'Date', :content=>"Today"
        end
      end
      
      it "*right setting should override *type setting" do
        Card['Jim+birthday'].raw_content.should == 'Today'
      end

      it "should defer to normal content when *structure rule's content is (exactly) '_self'" do
        Account.as_bot { Card.create! :name=>'Jim+birthday+*self+*structure', :content=>'_self' }
        Card['Jim+birthday'].raw_content.should == 'Yesterday'
      end
    end
  end
  
end


