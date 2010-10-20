require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.dirname(__FILE__) + '/../../test/fixtures/shared_data'   
FUTURE = SharedData::FUTURE


describe "Card" do
  before do
    Timecop.travel(FUTURE)  # make sure we're ahead of all the test data
  end 

  describe "#watchers" do
    it "returns users watching this card specifically" do
      Card["All Eyes On Me"].watchers.should == ["Sara", "John"]
    end
  
    it "returns users watching cards of this type" do
      Card["Sunglasses"].watchers.should == ["Sara"]
    end
  end
  
  describe "#card_watchers" do
    it "returns users watching this card specifically" do
      Card["All Eyes On Me"].card_watchers.should == ["Sara", "John"]
    end
  end
  
  describe "#type_watchers" do
    it "returns users watching cards of this type" do
      Card["Sunglasses"].type_watchers.should == ["Sara"]
    end
  end    
end   
  
describe "On Card Changes" do
  before do
    User.as(:john)           
    Timecop.travel(FUTURE)  # make sure we're ahead of all the test data
  end
  
  it "sends notifications of edits" do
    Mailer.should_receive(:deliver_change_notice).with( User.find_by_login('sara'), Card["Sara Watching"], "edited", "Sara Watching" )
    Card["Sara Watching"].update_attributes :content => "A new change"
  end
                                  
  it "sends notifications of additions" do
    new_card = Card.new :name => "Microscope", :type => "Optic"
    Mailer.should_receive(:deliver_change_notice).with( User.find_by_login('sara'), new_card,"added", "Optic"  )
    new_card.save!
  end 
  
  it "sends notification of updates" do
    Mailer.should_receive(:deliver_change_notice).with( User.find_by_login('sara'), Card["Sunglasses"], "updated", "Optic")
    Card["Sunglasses"].update_attributes :type => "Basic"
  end
  
  it "does not send notification to author of change" do
    Mailer.should_receive(:deliver_change_notice).with( User.find_by_login('sara'), Card["All Eyes On Me"],"edited", "All Eyes On Me")
    Card["All Eyes On Me"].update_attributes :content => "edit by John"
    # note no message to John
  end
end
