require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../pattern_spec_helper')

describe Pattern do
  it "module exists and autoloads" do
    Pattern.should be_true
  end    
  
  context :matching_subclass do
    it "chooses appropriate class" do
      Pattern.class_for( :right => "author" ).should == RightNamePattern
    end
  end   
  
  context :key_for_spec do
    it "generates key for Type spec" do
      Pattern.key_for_spec( :type => "Book" ).should == "Type:Book"
    end
    
    it "generates key for RightName spec" do
      Pattern.key_for_spec( :right => "author" ).should == "RightName:author"
    end
  end
          
  context :keys_for_card do
    it "generates keys from multiple patterns for card" do                    
      ia = Card.new( :name => "Illiad+author" )
      Pattern.keys_for_card( ia ).should == ["Type:Basic","RightName:author","LeftTypeRightName:Book:author"]
    end
  end
end

describe RightNamePattern do
  it_accepts :right => "author"
  it_rejects :type => "Book", :right => "author"
  it_generates :key => "RightName:author", :from => Card.new( :name => "Illiad+author" )
  it_generates :key => "RightName:author", :from => { :right => "author" }
end
                              
describe TypePattern do
  it_accepts :type => "Book"
  it_rejects :type => "Book", :right => "author"      
  it_generates :key => "Type:Book", :from => Card.new( :type => "Book" )
  it_generates :key => "Type:Book", :from => { :type => "Book" }
end

describe LeftTypeRightNamePattern do
  it_accepts :left => {:type=>"Book"}, :right => "author"
  it_rejects :type => "Book"
  it_rejects :right => "author"
  it_generates :key => "LeftTypeRightName:Book:author", :from => Card.new( :name=>"Illiad+author" )
  it_generates :key => "LeftTypeRightName:Book:author", :from => { :left=>{:type=>"Book"}, :right=>"author" }
end
                                                