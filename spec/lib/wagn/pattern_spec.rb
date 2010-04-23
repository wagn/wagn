require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../pattern_spec_helper')

describe Wagn::Pattern do
  it "module exists and autoloads" do
    Wagn::Pattern.should be_true
  end    
  
  describe :set_names do
    it "returns solo, type, all for simple cards" do
      Wagn::Pattern.set_names( Card.new( :name => "AnewCard" )).should == [
        "AnewCard+*self","Basic+*type","*all"
      ]
    end
    
    it "returns set names for junction cards" do
      Wagn::Pattern.set_names( Card.new( :name=>"Illiad+author" )).should == [
        "Illiad+author+*self", "Book+author+*type plus right","author+*right","Basic+*type","*all"
      ]
    end
  end
  
  describe :css_names do
    it "returns self, type, all for simple cards" do
      Wagn::Pattern.css_names( Card.new( :name => "*AnewCard")).should == 
        "ALL TYPE-basic SELF-Xanew_card"
    end

    it "returns set names for junction cards" do
      Wagn::Pattern.css_names( Card.new( :name=>"Illiad+author" )).should == 
        "ALL TYPE-basic RIGHT-author TYPE_PLUS_RIGHT-book-author SELF-illiad-author"
    end
  end
  
  describe :label do
    it "returns label for name" do
      Wagn::Pattern.label('address+*right').should== "Cards ending in +address"
    end
  end
end

describe Wagn::RightNamePattern do
  it_generates :name => "author+*right", :from => Card.new( :name => "Illiad+author" )
  it_generates :name => "author+*right", :from => Card.new( :name => "+author" )
  
  describe :label do
    it "returns label for name" do
      Wagn::RightNamePattern.label('address+*right').should== "Cards ending in +address"
    end
  end
end
                              
describe Wagn::TypePattern do
  it_generates :name => "Book+*type", :from => Card.new( :type => "Book" )
end

describe Wagn::AllPattern do
  it_generates :name => "*all", :from => Card.new( :type => "Book" )
end

describe Wagn::LeftTypeRightNamePattern do
  it_generates :name => "Book+author+*type plus right", :from => Card.new( :name=>"Illiad+author" )
end
     