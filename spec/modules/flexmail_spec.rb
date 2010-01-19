require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Flexmail do
  it("is ready for the whole test suite") { false.should be_true } 
  
  describe ".expand_list_setting" do
    before do
      # note cards 'A' and 'Z' are in shared_data.
      @context_card = CachedCard.get("A") # refers to 'Z'
    end
    
    it "returns item for each line of basic setting" do
      setting_card = Card.new :name=>"foo", :content => "X\nY" 
      Flexmail.expand_list_setting( setting_card, @context_card ).should == ["X","Y"]
    end
    
    it "returns pointee's content for pointer setting" do
      setting_card = Card.new :name=>"foo", :type=>"Pointer", :content => "[[Z]]" 
      Flexmail.expand_list_setting( setting_card, @context_card ).should == ["I'm here to be referenced to"]
    end
    
    it "returns search results content for search setting" do
      setting_card = Card.new :name=>"foo", :type=>"Search", :content => %[{"name":"Z"}] 
      Flexmail.expand_list_setting( setting_card, @context_card ).should == ["I'm here to be referenced to"]
    end
    
    it "handles searches relative to context card" do
      setting_card = Card.new :name=>"foo", :type=>"Search", :content => %[{"referred_to_by":"_self"}]
      Flexmail.expand_list_setting( setting_card, @context_card ).should == ["I'm here to be referenced to"]
    end
  end
  
  describe ".expand_content_setting" do
    before do
      # note cards 'A' and 'Z' are in shared_data.
      @context_card = CachedCard.get("A") # refers to 'Z'
    end

    it "returns content for basic setting" do
      setting_card = Card.new :name=>"foo", :content => "X" 
      Flexmail.expand_content_setting( setting_card, @context_card ).should == "X"
    end
    
    it "processes inclusions relative to context card" do
      setting_card = Card.new :name=>"foo", :content => "{{_self+B|naked}}"
      Flexmail.expand_content_setting( setting_card, @context_card ).should == "AlphaBeta"
    end
  end
  
  describe "card creation hook" do
    before do
      User.as :wagbot
      Card.create! :type=>"Pointer", :name => "Book+*type+*send", :content=>"[[mailconfig]]"
      Card.create! :name => "mailconfig+*to", :content => "joe@user.com"
    end
    
    it "calls to flexmail mailer when config is present" do
      Mailer.should_receive(:deliver_flexmail) do |card, config|
        card.name.should == "TaoTeChing"
        config.name.should == "mailconfig"
      end
      Card.create :type => "Book", :name => "TaoTeChing"
    end
  end
  
end