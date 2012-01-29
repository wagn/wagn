require File.expand_path('../spec_helper', File.dirname(__FILE__))
require File.expand_path('../../test/seed', File.dirname(__FILE__))   
FUTURE = SharedData::FUTURE


describe "Card" do
  before do
    Timecop.travel(FUTURE)  # make sure we're ahead of all the test data
    @just_s = [Card["Sara"].id]
    @s_and_j= [Card["Sara"].id, Card["John"].id]
  end 

  describe "#watchers" do
    it "returns users watching this card specifically" do
      Card["All Eyes On Me"].watchers.should == @s_and_j
    end
  
    it "returns users watching cards of this type" do
      Card["Sunglasses"].watchers.should == @just_s
    end
  end
  
  describe "#card_watchers" do
    it "returns users watching this card specifically" do
      Card["All Eyes On Me"].watcher_pairs(false).should == @s_and_j
    end
  end
  
  describe "#type_watchers" do
    it "returns users watching cards of this type" do
      Card["Sunglasses"].watcher_pairs(false, :type).should == @just_s
    end
  end    
end   
  
describe "On Card Changes" do
  before do
    Card.user= :john           
    Timecop.travel(FUTURE)  # make sure we're ahead of all the test data
  end
  
  it "sends notifications of edits" do
    Mailer.should_receive(:change_notice).with( Card['Sara'].id, Card["Sara Watching"], "edited", "Sara Watching", nil )
    Card["Sara Watching"].update_attributes :content => "A new change"
  end
                                  
  it "sends notifications of additions" do
    new_card = Card.new :name => "Microscope", :type => "Optic"
    Mailer.should_receive(:change_notice).with( Card['Sara'].id, new_card,"added", "Optic", nil  )
    new_card.save!
  end 
  
  it "sends notification of updates" do
    Mailer.should_receive(:change_notice).with( Card['Sara'].id, Card["Sunglasses"], "updated", "Optic", nil)
    Card["Sunglasses"].update_attributes :codename => "SUNGLASSES"
  end
  
  it "does not send notification to author of change" do
    Mailer.should_receive(:change_notice).with( Card['Sara'].id, Card["All Eyes On Me"],"edited", "All Eyes On Me", nil)
    Card["All Eyes On Me"].update_attributes :content => "edit by John"
    # note no message to John
  end
end
