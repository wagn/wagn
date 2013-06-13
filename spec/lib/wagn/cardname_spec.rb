# -*- encoding : utf-8 -*-
  # encoding: utf-8
require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe Card::Name do

  describe "#key" do
    it "should remove spaces" do
      "this    Name".to_name.key.should == "this_name"
    end

    it "should have initial _ for initial cap" do
      "This Name".to_name.key.should == "this_name"
    end

    it "should have initial _ for initial cap" do
      "_This Name".to_name.key.should == "this_name"
    end

    it "should singularize" do
      "ethans".to_name.key.should == "ethan"
    end

    it "should underscore" do
      "ThisThing".to_name.key.should == "this_thing"
    end

    it "should handle plus cards" do
      "ThisThing+Ethans".to_name.key.should == "this_thing+ethan"
    end

    it "should retain * for star cards" do
      "*right".to_name.key.should == "*right"
    end

    it "should not singularize double s's" do
      "grass".to_name.key.should == 'grass'
    end

    it "should not singularize letter 'S'" do
      'S'.to_name.key.should == 's'
    end

    it "should handle unicode characters" do
      "Mañana".to_name.key.should == 'mañana'
    end

    it "should handle weird initial characters" do
      '__you motha @#$'.to_name.key.should == 'you_motha'
      '?!_you motha @#$'.to_name.key.should == 'you_motha'
    end

    it "should allow numbers" do
      "3way".to_name.key.should == '3way'
    end

    it "internal plurals" do
      "cards hooks label foos".to_name.key.should == 'card_hook_label_foo'
    end

    it "should handle html entities" do
      # This no longer takes off the s, is singularize broken now?
      "Jean-fran&ccedil;ois Noubel".to_name.key.should == 'jean_françoi_noubel'
    end
  end





  describe "#url_key" do
    cardnames = ["GrassCommons.org", 'Oh you @##', "Alice's Restaurant!", "PB &amp; J", "Mañana"].map(&:to_name)

    cardnames.each do |cardname|
      it "should have the same key as the name" do
        k, k2 = cardname.key, cardname.url_key
        #warn "cn tok #{cardname.inspect}, #{k.inspect}, #{k2.inspect}"
        k.should == k2.to_name.key
      end
    end
  end

  describe "#valid" do
    it "accepts valid names" do
      "this+THAT".to_name.should be_valid
      "THE*ONE*AND$!ONLY".to_name.should be_valid
    end

    it "rejects invalide names" do
      "Tes~sd".to_name.should_not be_valid
      "TEST/DDER".to_name.should_not be_valid
    end
  end

  describe "#left_name" do
    it "returns nil for non junction" do
      "a".to_name.left_name.should == nil
    end

    it "returns parent for parent" do
      "a+b+c+d".to_name.left_name.should == "a+b+c"
    end
  end

  describe "#tag_name" do
    it "returns last part of plus card" do
      "a+b+c".to_name.tag.should == "c"
    end

    it "returns name of simple card" do
      "a".to_name.tag.should == "a"
    end
  end

  describe "#safe_key" do
    it "subs pluses & stars" do
      "Alpha?+*be-ta".to_name.safe_key.should == "alpha-Xbe_tum"
    end
  end

  describe "#replace_part" do
    it "replaces first name part" do
      'a+b'.to_name.replace_part('a','x').to_s.should == 'x+b'
    end
    it "replaces second name part" do
      'a+b'.to_name.replace_part('b','x').to_s.should == 'a+x'
    end
    it "replaces two name parts" do
      'a+b+c'.to_name.replace_part('a+b','x').to_s.should == 'x+c'
    end
    it "doesn't replace two part tag" do
      'a+b+c'.to_name.replace_part('b+c','x').to_s.should == 'a+b+c'
    end
  end

  describe "Cardnames star handling" do
    it "recognizes star cards" do
      '*a'.to_name.star?.should be_true
    end

    it "doesn't recognize star cards with plusses" do
      '*a+*b'.to_name.star?.should be_false
    end

    it "recognizes rstar cards" do
      'a+*a'.to_name.rstar?.should be_true
    end

    it "doesn't recognize star cards as rstar" do
      '*a'.to_name.rstar?.should be_false
    end

    it "doesn't recognize non-star or star left" do
      '*a+a'.to_name.rstar?.should be_false
    end
  end

  describe "trait_name?" do
    it "returns true for content codename" do
      "bazoinga+*right+*structure".to_name.trait_name?(:structure).should be_true
    end

    it "handles arrays" do
      "bazoinga+*right+*structure".to_name.trait_name?(:structure, :default).should be_true
    end

    it "returns false for non-template" do
      "bazoinga+*right+nontent".to_name.trait_name?(:structure).should be_false
    end
  end

  describe "#to_absolute" do
    it "handles _self, _whole, _" do
      "_self".to_name.to_absolute("foo").should == "foo"
      "_whole".to_name.to_absolute("foo").should == "foo"
      "_".to_name.to_absolute("foo").should == "foo"
    end

    it "handles _left" do
      "_left+Z".to_name.to_absolute("A+B+C").should == "A+B+Z"
    end

    it "handles white space" do
      "_left + Z".to_name.to_absolute("A+B+C").should == "A+B+Z"
    end

    it "handles _right" do
      "_right+bang".to_name.to_absolute("nutter+butter").should == "butter+bang"
      "C+_right".to_name.to_absolute("B+A").should == "C+A"
    end

    it "handles leading +" do
      "+bug".to_name.to_absolute("hum").should == "hum+bug"
    end

    it "handles trailing +" do
      "bug+".to_name.to_absolute("tracks").should == "bug+tracks"
    end

    it "handles _(numbers)" do
      "_1".to_name.to_absolute("A+B+C").should == "A"
      "_1+_2".to_name.to_absolute("A+B+C").should == "A+B"
      "_2+_3".to_name.to_absolute("A+B+C").should == "B+C"
    end

    it "handles _LLR etc" do
      "_R".to_name.to_absolute("A+B+C+D+E").should    == "E"
      "_L".to_name.to_absolute("A+B+C+D+E").should    == "A+B+C+D"
      "_LR".to_name.to_absolute("A+B+C+D+E").should   == "D"
      "_LL".to_name.to_absolute("A+B+C+D+E").should   == "A+B+C"
      "_LLR".to_name.to_absolute("A+B+C+D+E").should  == "C"
      "_LLL".to_name.to_absolute("A+B+C+D+E").should  == "A+B"
      "_LLLR".to_name.to_absolute("A+B+C+D+E").should == "B"
      "_LLLL".to_name.to_absolute("A+B+C+D+E").should == "A"
    end

    context "mismatched requests" do
      it "returns _self for _left or _right on simple cards" do
        "_left+Z".to_name.to_absolute("A").should == "A+Z"
        "_right+Z".to_name.to_absolute("A").should == "A+Z"
      end

      it "handles bogus numbers" do
        "_1".to_name.to_absolute("A").should == "A"
        "_1+_2".to_name.to_absolute("A").should == "A+A"
        "_2+_3".to_name.to_absolute("A").should == "A+A"
      end

      it "handles bogus _llr requests" do
           "_R".to_name.to_absolute("A").should == "A"
           "_L".to_name.to_absolute("A").should == "A"
          "_LR".to_name.to_absolute("A").should == "A"
          "_LL".to_name.to_absolute("A").should == "A"
         "_LLR".to_name.to_absolute("A").should == "A"
         "_LLL".to_name.to_absolute("A").should == "A"
        "_LLLR".to_name.to_absolute("A").should == "A"
        "_LLLL".to_name.to_absolute("A").should == "A"
      end
    end

    it "does session user substitution" do
      "_user".to_name.to_absolute("A").should == Account.current.name
      Account.as_bot do
        "_user".to_name.to_absolute("A").should == Account.current.name
      end
    end
  end

  describe "#to_show" do
    it "ignores ignorables" do
         'you+awe'.to_name.to_show('you').should == '+awe'
      'me+you+awe'.to_name.to_show('you').should == 'me+awe' #HMMM..... what should this do?
      'me+you+awe'.to_name.to_show('me' ).should == '+you+awe'
      'me+you+awe'.to_name.to_show('me','you').should == '+awe'
          'me+you'.to_name.to_show('me','you').should == 'me+you'
         '?a?+awe'.to_name.to_show('A').should == '+awe'
            '+awe'.to_name.to_show().should == '+awe'
    end
  end

end
