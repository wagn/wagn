require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Card do
  context "new" do
    it "gracefully handles explicit nil as parameters" do
      Card.new( nil ).should be_instance_of(Card::Basic)
    end
  end
end