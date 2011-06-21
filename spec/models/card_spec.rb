require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Card do
  context "new" do
    it "gracefully handles explicit nil as parameters" do
      Card.new( nil ).should be_instance_of(Card)
    end
    
    it "gracefully handles explicit nil name" do
      Card.new( :name => nil ).should be_instance_of(Card)
    end
  end
  
  describe "module inclusion" do
    before do
      @c = Card.new :type=>'Search', :name=>'Module Inclusion Test Card'
    end
    
    it "gets needed methods after new" do
      @c.respond_to?( :get_spec ).should be_true
    end
    
    it "gets needed methods after save" do
      @c.save!
      @c.respond_to?( :get_spec ).should be_true
    end
    
    it "gets needed methods after find" do
      @c.save!
      c = Card.find_by_name(@c.name)
      c.respond_to?( :get_spec ).should be_true
    end
    
    it "gets needed methods after fetch" do
      @c.save!
      c = Card.fetch(@c.name)
      c.respond_to?( :get_spec ).should be_true
    end
  end
  
  describe "#create" do 
    it "calls :before_save, :before_create, :after_save, and :after_create hooks" do
      [:before_save, :before_create, :after_save, :after_create].each do |hookname|
        Wagn::Hook.should_receive(:call).with(hookname, instance_of(Card))
      end 
      User.as :wagbot do
        Card.create :name => "testit"
      end
    end
  end
end