require File.expand_path('../../../spec_helper', File.dirname(__FILE__))
require File.expand_path('../../../pattern_spec_helper', File.dirname(__FILE__))

describe Wagn::Model::Pattern do
  it "module exists and autoloads" do
    Wagn::Model::Pattern.should be_true
  end    
  
  before do
    User.as :wagbot
  end
  
  describe :set_names do
    it "returns self, type, all for simple cards" do
      card = Card.new( :name => "AnewCard" )
      card.set_names.should == [ "Basic+*type","*all"]
      card.save!
      card = Card.fetch("AnewCard")
      card.set_names.should == [ "AnewCard+*self","Basic+*type","*all"]
    end

    it "returns set names for simple star cards" do
      Card.fetch('*update').set_names.should == [ 
        "*update+*self","*star","Setting+*type","*all"
      ]
    end
    
    it "returns set names for junction cards" do
      Card.new( :name=>"Illiad+author" ).set_names.should == [
        "Book+author+*type plus right","author+*right","Basic+*type","*all plus","*all"
      ]
    end

    it "returns set names for compound star cards" do
      Card.new( :name=>"Illiad+*to" ).set_names.should == [
        "Book+*to+*type plus right","*to+*right","*rstar","Phrase+*type","*all plus","*all"
      ]
    end
  end

  describe :junction_only? do
    cases = {"Book+*to+*type plus right" => true, "*to+*right" => true,"*rstar" => true, "Phrase+*type"=>false,"*all plus"=>false,"*all"=>false }
    cases.keys.find do |k| Card.new(:name=>k).junction_only?() end
  end

  describe :method_keys do
    it "returns correct set names for simple cards" do
      card = Card.new( :name => "AnewCard" )
      card.method_keys.should == [ "basic_type", ""]
      card.save!
      card = Card.fetch("AnewCard")
      card.method_keys.should == [ "anew_card_self","basic_type",""]
    end
    
  end
  
  describe :css_names do
    it "returns css names for simple star cards" do
      card = Card.new( :name => "*AnewCard")
      card.css_names.should == "ALL TYPE-basic STAR"
      card.save!
      card = Card.fetch("*AnewCard")
      card.css_names.should == "ALL TYPE-basic STAR SELF-Xanew_card"
    end

    it "returns set names for junction cards" do
      card=Card.new( :name=>"Illiad+author" )
      card.css_names.should == "ALL ALL_PLUS TYPE-basic RIGHT-author TYPE_PLUS_RIGHT-book-author"
      card.save!
      card = Card.fetch("Illiad+author")      
      card.css_names.should == "ALL ALL_PLUS TYPE-basic RIGHT-author TYPE_PLUS_RIGHT-book-author SELF-illiad-author"
    end
  end
  
  describe :label do
    it "returns label for name" do
      Card.new(:name=>'address+*right').label.should== "Cards ending in +address"
    end
  end
end

describe Wagn::Model::RightNamePattern do
  it_generates :name => "author+*right", :from => Card.new( :name => "Illiad+author" )
  it_generates :name => "author+*right", :from => Card.new( :name => "+author" )
  
  describe :label do
    it "returns label for name" do
      Card.new(:name=>'address+*right').label.should== "Cards ending in +address"
    end
  end
end
                              
describe Wagn::Model::TypePattern do
  it_generates :name => "Book+*type", :from => Card.new( :type => "Book" )
end

describe Wagn::Model::AllPlusPattern do
  it_generates :name => "*all plus", :from => Card.new( :name => "Book+author" )
end
  

describe Wagn::Model::AllPattern do
  it_generates :name => "*all", :from => Card.new( :type => "Book" )
end

describe Wagn::Model::LeftTypeRightNamePattern do
  it_generates :name => "Book+author+*type plus right", :from => Card.new( :name=>"Illiad+author" )
end
     
