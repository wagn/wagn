require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Card do
  context "new" do
    it "gracefully handles explicit nil as parameters" do
      Card.new( nil ).should be_instance_of(Card::Basic)
    end
    
    it "gracefully handles explicit nil name" do
      Card.new( :name => nil ).should be_instance_of(Card::Basic)
    end
  end
  
  describe "#create" do 
    it "calls :before_save, :before_create, :after_save, and :after_create hooks" do
      [:before_create, :before_save, :after_save, :after_create].each do |hookname|
        Wagn::Hook.should_receive(:call).with(hookname, instance_of(Card::Basic))
      end 
      User.as :wagbot do
        Card.create :name => "testit"
      end
    end
  end
end
