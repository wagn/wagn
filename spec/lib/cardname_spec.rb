# encoding: utf-8
require_relative '../spec_helper'

describe Wagn::Cardname do
  
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
    
    it "should not singularize letter 'S'" do
      'S'.to_key.should == 's'
    end
    
    it "should handle unicode characters" do
      "Mañana".to_key.should == 'mañana'
    end
    
    it "should handle weird initial characters" do
      '?!_you motha @#$'.to_key.should == 'you_motha'
    end
    
    it "should allow numbers" do
      "3way".to_key.should == '3way'
    end
    
    it "should handle html entities" do
      "Jean-fran&ccedil;ois Noubel".to_key.should == 'jean_françoi_noubel'
    end
  end
  
  describe "#to_absolute" do
    it "handles _self, _whole, _" do
      "_self".to_absolute("foo").should == "foo"
      "_whole".to_absolute("foo").should == "foo"
      "_".to_absolute("foo").should == "foo"
    end
    
    it "handles _left" do
      "_left+Z".to_absolute("A+B+C").should == "A+B+Z"
    end
    
    it "handles _right" do
      "_right+bang".to_absolute("nutter+butter").should == "butter+bang"
      "C+_right".to_absolute("B+A").should == "C+A"
    end
    
    it "handles leading +" do
      "+bug".to_absolute("hum").should == "hum+bug"
    end
    
    it "handles trailing +" do
      "bug+".to_absolute("tracks").should == "bug+tracks"
    end
    
    it "handles _(numbers)" do
      "_1".to_absolute("A+B+C").should == "A"
      "_1+_2".to_absolute("A+B+C").should == "A+B"
      "_2+_3".to_absolute("A+B+C").should == "B+C"
    end

    it "handles _LLR etc" do
      "_R".to_absolute("A+B+C+D+E").should    == "E"
      "_L".to_absolute("A+B+C+D+E").should    == "A+B+C+D"
      "_LR".to_absolute("A+B+C+D+E").should   == "D"
      "_LL".to_absolute("A+B+C+D+E").should   == "A+B+C"
      "_LLR".to_absolute("A+B+C+D+E").should  == "C"
      "_LLL".to_absolute("A+B+C+D+E").should  == "A+B"
      "_LLLR".to_absolute("A+B+C+D+E").should == "B"
      "_LLLL".to_absolute("A+B+C+D+E").should == "A"
    end
    
    context "mismatched requests" do
      it "returns _self for _left or _right on non-junctions" do
        "_left+Z".to_absolute("A").should == "A+Z"
        "_right+Z".to_absolute("A").should == "A+Z"
      end

      it "handles bogus numbers" do
        "_1".to_absolute("A").should == "A"
        "_1+_2".to_absolute("A").should == "A+A"
        "_2+_3".to_absolute("A").should == "A+A"
      end
      
      it "handles bogus _llr requests" do
           "_R".to_absolute("A").should == "A"
           "_L".to_absolute("A").should == "A"
          "_LR".to_absolute("A").should == "A"
          "_LL".to_absolute("A").should == "A"
         "_LLR".to_absolute("A").should == "A"
         "_LLL".to_absolute("A").should == "A"
        "_LLLR".to_absolute("A").should == "A"
        "_LLLL".to_absolute("A").should == "A"
      end
    end
  end
  


  describe "#to_url_key" do
    cardnames = ["GrassCommons.org", 'Oh you @##', "Alice's Restaurant!", "PB &amp; J", "Mañana"]
  
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
  
  describe "#left_name" do
    it "returns nil for non junction" do
      "a".left_name.should == nil
    end
    
    it "returns parent for parent" do
      "a+b+c+d".left_name.should == "a+b+c"
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
