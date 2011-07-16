  require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../pattern_spec_helper')

describe Wagn::Pattern do
  it "module exists and autoloads" do
    Wagn::Pattern.should be_true
  end    
  
  before do
    User.as :wagbot
  end
  
  describe :set_names do
    it "returns self, type, all for simple cards" do
      card = Card.new( :name => "AnewCard" )
      Wagn::Pattern.set_names( card).should == [ "Basic+*type","*all"]
      card.save!
      card = Card.fetch("AnewCard")
      Wagn::Pattern.set_names( card).should == [ "AnewCard+*self","Basic+*type","*all"]
    end

    it "returns set names for simple star cards" do
      Wagn::Pattern.set_names(Card.fetch("*update")).should == [ 
        "*update+*self","*star","Setting+*type","*all"
      ]
    end

    
    it "returns set names for junction cards" do
      Wagn::Pattern.set_names( Card.new( :name=>"Illiad+author" )).should == [
        "Book+author+*type plus right","author+*right","Basic+*type","*all plus","*all"
      ]
    end

    it "returns set names for compound star cards" do
      Wagn::Pattern.set_names( Card.new( :name=>"Illiad+*to" )).should == [
        "Book+*to+*type plus right","*to+*right","*to+*rstar","Phrase+*type","*all plus","*all"
      ]
    end
  end

  describe :method_keys do
    it "returns correct set names for simple cards" do
      card = Card.new( :name => "AnewCard" )
      Wagn::Pattern.method_keys( card).should == [ "basic_type", ""]
      card.save!
      card = Card.fetch("AnewCard")
      Wagn::Pattern.method_keys( card).should == [ "anew_card_self","basic_type",""]
    end
    
  end
  
  describe :css_names do
    it "returns css names for simple star cards" do
      card = Card.new( :name => "*AnewCard")
      Wagn::Pattern.css_names( card ).should == "ALL TYPE-basic STAR"
      card.save!
      card = Card.fetch("*AnewCard")
      Wagn::Pattern.css_names( card ).should == "ALL TYPE-basic STAR SELF-Xanew_card"
    end

    it "returns set names for junction cards" do
      card=Card.new( :name=>"Illiad+author" )
      Wagn::Pattern.css_names( card ).should == "ALL ALL_PLUS TYPE-basic RIGHT-author TYPE_PLUS_RIGHT-book-author"
      card.save!
      card = Card.fetch("Illiad+author")      
      Wagn::Pattern.css_names( card ).should == "ALL ALL_PLUS TYPE-basic RIGHT-author TYPE_PLUS_RIGHT-book-author SELF-illiad-author"
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

describe Wagn::AllPlusPattern do
  it_generates :name => "*all plus", :from => Card.new( :name => "Book+author" )
end
  

describe Wagn::AllPattern do
  it_generates :name => "*all", :from => Card.new( :type => "Book" )
end

describe Wagn::LeftTypeRightNamePattern do
  it_generates :name => "Book+author+*type plus right", :from => Card.new( :name=>"Illiad+author" )
end
     
