require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Card do
  before do
    User.as(:wagbot)
  end

  context "settings" do
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
  
  context "cascading settings" do
    before do
      Card.create :name => "*all+*edit help", :content => "edit any kind of card"
    end
    
    it "retrieves default setting" do
      Card.new( :type => "Book" ).setting('add help').should == "edit any kind of card"
    end
    
    it "retrieves primary setting" do
      Card.create :name => "*all+*add help", :content => "add any kind of card"
      Card.new( :type => "Book" ).setting('add help').should == "add any kind of card"
    end
    
    it "retrieves more specific default setting" do
      Card.create :name => "*all+*add help", :content => "add any kind of card"
      Card.create :name => "*Book+*type+*edit help", :content => "edit a Book"
      Card.new( :type => "Book" ).setting('add help').should == "add any kind of card"
    end
  end
end