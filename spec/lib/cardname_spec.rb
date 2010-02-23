require File.dirname(__FILE__) + '/../spec_helper'

describe Cardname do
  describe "#to_key" do
    it "should remove spaces" do
      "This Name".to_key.should == "this_name"
    end
  
    it "should singularize" do
      "ethans".to_key.should == "ethan"
    end                               
  
    it "should underscore" do 
      "ThisThing".to_key.should == "this_thing"
    end
  
    it "should handle plus cards" do
      "ThisThing+Ethans".to_key.should == "this_thing+ethan"
    end          
  
    it "should retain * for star cards" do
      "*right".to_key.should == "*right"
    end
  
    it "should not singularize double s's" do
      "grass".to_key.should == 'grass'    
    end
  end  

  describe "#to_url_key" do
    cardnames = ["GrassCommons.org", 'Oh you @##', "Alice's Restaurant!"]
  
    cardnames.each do |name| 
      it "should have the same key as the name" do
        name.to_key.should == name.to_url_key.to_key
      end
    end
  end       

  describe "#valid" do
    it "accepts valid names" do
      "this+THAT".should be_valid_cardname
      "THE*ONE*AND$!ONLY".should be_valid_cardname
    end           
    
    it "rejects invalide names" do
      "Tes~sd".should_not be_valid_cardname
      "TEST/DDER".should_not be_valid_cardname
    end
  end         
  
  describe "#parent_name" do
    it "returns nil for non junction" do
      "a".parent_name.should == nil
    end
    
    it "returns parent for parent" do
      "a+b+c+d".parent_name.should == "a+b+c"
    end
  end

  describe "#tag_name" do
    it "returns last part of plus card" do
      "a+b+c".tag_name.should == "c"  
    end
    
    it "returns name of simple card" do
      "a".tag_name.should == "a"
    end
  end

  describe "#css_name" do
    it "subs pluses & stars" do
      "Alpha?+*be-ta".css_name.should == "alpha-Xbe_tum"
    end
  end

  describe "#replace_part" do
    'a+b'.replace_part('a','x').should == 'x+b'
    'a+b+c'.replace_part('a+b','x').should == 'x+c'
    'a+b+c'.replace_part('b+c','x').should == 'a+b+c'    
  end  
end