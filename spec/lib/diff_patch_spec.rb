require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe String do
  describe "#to_words" do
    it "converts html to words" do
      "<p>this and <b>that</b></p>".to_words.should ==  [
        "<p>", "this", " ", "and", " ", "<b>", "that", "</b>", "</p>"
      ]
    end
  end
  
  describe "#split_twice" do
    it "splits on the first two occurences of delimiter" do
      "a:b:c:d:e".split_twice(":").should == ["a","b","c:d:e"]
    end
  end
end

describe DiffPatch do
  before do
    @old_string = "<p>this and <b>that</b></p>"
    @new_string = '<p class="foo">this or <b>that</b> and <i>those</i></p>'
    @expected_diff = "-0:<p>|;+0:<p class=\"foo\">|;-3:and|;+3:or|;+8: |;+9:and|;+10: |;+11:<i>|;+12:those|;+13:</i>"
  end
    
  describe ".diff" do
    it "converts a list of diffs to serialized string" do
      DiffPatch.diff( @old_string, @new_string ).should == @expected_diff
    end
  end
  
  describe ".patch" do
    it "applies a patch" do
      DiffPatch.patch( @old_string, @expected_diff ).should == @new_string
    end

    it "applies cleanly to changed string (merge)" do
      @forked_string = "<p>him and <b>her</b></p>"
      DiffPatch.patch( @forked_string, @expected_diff ).should ==
        '<p class="foo">him or <b>her</b> and <i>those</i></p>'
    end
  end
end

describe RevisionMerger do
  before do
    User.as :wagbot
    # FIXME?  this data will be wrong when the test data is regenerated- 
    #  best would be to fix the timestamps in test data generation.
    @revtest_dump = [
      "2010-04-22T12:46:55.786149-06:00::Wagn Bot::+0:first", 
      "2010-04-22T12:46:55.819985-06:00::Wagn Bot::-0:first|;+0:second", 
      "2010-04-22T12:46:55.846909-06:00::Wagn Bot::-0:second|;+0:third"
    ] 
    @clone = Card.create! :name => "revclone", :content => "whattup"
    @rm = RevisionMerger.new @clone 
    @revclone_dump =  [ 
      @rm.dump[0], 
      "2010-04-22T12:46:55.786149-06:00::Wagn Bot::-0:whattup|;+0:firstwhattup",
      "2010-04-22T12:46:55.819985-06:00::Wagn Bot::-0:firstwhattup|;+0:second", 
      "2010-04-22T12:46:55.846909-06:00::Wagn Bot::-0:second|;+0:third"
    ]
  end
  
  describe "#dump" do    
    it "dumps a list of revisions" do
      RevisionMerger.new( Card["revtest"] ).dump.should == @revtest_dump
    end 
  end
  
  describe "#load" do
    before do
      Rails.logger.level = ActiveSupport::BufferedLogger::Severity::DEBUG
    end
      
    it "loads revisions into a card" do
      @rm.load @revtest_dump 
      @rm.card.reload
      @rm.dump.should == @revclone_dump
    end
    
    it "does not duplicate revisions" do
      @rm.load @revtest_dump 
      @rm.load @revtest_dump 
      @rm.card.reload
      @rm.dump.should == @revclone_dump
    end
  end
end

describe CardMerger do
  before do
    User.as :wagbot
    @dump = "--- \n" +
      "revtest: \n"+
      "  revisions: \n"+
      "  - 2010-04-22T12:46:55.786149-06:00::Wagn Bot::+0:first\n" +
      "  - 2010-04-22T12:46:55.819985-06:00::Wagn Bot::-0:first|;+0:second\n" +
      "  - 2010-04-22T12:46:55.846909-06:00::Wagn Bot::-0:second|;+0:third\n" +
      "  type: Basic\n"
  end
  
  describe ".dump" do
    it "dumps a given list of cards to txt format" do
      CardMerger.dump( ["revtest"] ).should == @dump
    end
  end
  
  describe ".load" do
    it "loads cards from a txt format" do
      Card["revtest"].destroy_without_trash
      CardMerger.load @dump
      c = Card["revtest"]
      c.revisions.map(&:content).should == ["","first","second","third"]
    end
  end
end

