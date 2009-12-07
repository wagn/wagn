require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Card do
  before do
    User.as(:wagbot)
  end
  
  context "settings" do
    it "retrieves Set based value" do
      Card.create :name => "Book cards", :type => "Set", :content => "{\"type\": \"Book\"}"
      Card.create :name => "Book cards+*new", :content => "authorize"
      Card.new( :type => "Book" ).setting('new').should == "authorize"
    end                                          
    
    it "retrieves default values" do
      Card.create :name => "all Basic cards", :type => "Set", :content => "{\"type\": \"Basic\"}"  #defaults should work when other Sets are present
      Card.create :name => "*all+*new", :content => "lobotomize"
      Card.default_setting('new').should == "lobotomize"
      Card.new( :type => "Basic" ).setting('new').should == "lobotomize"
    end                                                                 
    
    it "retrieves single values" do
      Card.create :name => '*solo+*rform', :type=>'Set', :content=>'{"name":"_self"}'
      Card.create :name => "banana+*solo+*edit", :content => "pebbles"
      Card["banana"].setting('edit').should == "pebbles"
    end
  end
  
end