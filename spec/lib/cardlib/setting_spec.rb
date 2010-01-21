require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Card do
  before do
    User.as(:wagbot)
  end
  
  describe "#settings" do
    it "retrieves Set based value" do
      Card.create :name => "Book+*type+*add help", :content => "authorize"
      Card.new( :type => "Book" ).setting('add help').should == "authorize"
    end                                          
    
    it "retrieves default values" do
      Card.create :name => "all Basic cards", :type => "Set", :content => "{\"type\": \"Basic\"}"  #defaults should work when other Sets are present
      Card.create :name => "*all+*add help", :content => "lobotomize"
      Card.default_setting('add help').should == "lobotomize"
      Card.new( :type => "Basic" ).setting('add help').should == "lobotomize"
    end                                                                 
    
    it "retrieves single values" do
      Card.create :name => "banana+*self+*edit help", :content => "pebbles"
      Card["banana"].setting('edit help').should == "pebbles"
    end
  end
  
  describe "#list_items" do
    it "returns item for each line of basic content" do
      Card.new( :name=>"foo", :content => "X\nY" ).list_items.should == ["X","Y"]
    end

    it "returns list of card names for search" do
      c = Card.new( :name=>"foo", :type=>"Search", :content => %[{"name":"Z"}])
      c.list_items.should == ["Z"]
    end
    
    it "handles searches relative to context card" do
      context_card = CachedCard.get("A") # refers to 'Z'
      c = Card.new :name=>"foo", :type=>"Search", :content => %[{"referred_to_by":"_self"}]
      c.list_items( context_card ).should == ["Z"]
    end
  end

  describe "#list_cards" do
    # FIXME: missing tests here.
  end
  
  describe "#extended_list" do
    it "returns pointee's content for pointer setting" do
      c = Card.new(:name=>"foo", :type=>"Pointer", :content => "[[Z]]")
      c.extended_list.should == ["I'm here to be referenced to"]
    end
  end
  
  describe "#contextual_content" do
    it "returns content for basic setting" do
      Card.new(:name=>"foo", :content => "X").contextual_content.should == "X"
    end
    
    it "processes inclusions relative to context card" do
      context_card = CachedCard.get("A") # refers to 'Z'
      c = Card.new(:name=>"foo", :content => "{{_self+B|naked}}")
      c.contextual_content( context_card ).should == "AlphaBeta"
    end
  end
  
  
end