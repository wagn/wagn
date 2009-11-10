require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../pattern_spec_helper')

describe Pattern do
  it "module exists and autoloads" do
    Pattern.should be_true
  end    
  
  context :create do
    it "chooses appropriate class" do
      Pattern.create( :right => "author" ).should be_instance_of(RightNamePattern)
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
                                                