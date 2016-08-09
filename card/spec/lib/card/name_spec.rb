# -*- encoding : utf-8 -*-

describe Card::Name do
  describe "#key" do
    it "should lowercase and underscore" do
      expect("This Name".to_name.key).to eq("this_name")
    end

    it "should remove spaces" do
      expect("this    Name".to_name.key).to eq("this_name")
    end

    describe "underscores" do
      it "should be treated like spaces" do
        expect("weird_ combo".to_name.key).to eq("weird  combo".to_name.key)
      end

      it "should not impede pluralization checks" do
        expect("Mamas_and_Papas".to_name.key).to(
          eq("Mamas and Papas".to_name.key)
        )
      end

      it "should be removed when before first word character" do
        expect("_This Name".to_name.key).to eq("this_name")
      end
    end

    it "should singularize" do
      expect("ethans".to_name.key).to eq("ethan")
    end

    it "should change CamelCase to snake case" do
      expect("ThisThing".to_name.key).to eq("this_thing")
    end

    it "should handle plus cards" do
      expect("ThisThing+Ethans".to_name.key).to eq("this_thing+ethan")
    end

    it "should retain * for star cards" do
      expect("*right".to_name.key).to eq("*right")
    end

    it "should not singularize double s's" do
      expect("grass".to_name.key).to eq("grass")
    end

    it "should not singularize letter 'S'" do
      expect("S".to_name.key).to eq("s")
    end

    it "should handle unicode characters" do
      expect("Mañana".to_name.key).to eq("mañana")
    end

    it "should handle weird initial characters" do
      expect("__you motha @\#$".to_name.key).to eq("you_motha")
      expect("?!_you motha @\#$".to_name.key).to eq("you_motha")
    end

    it "should allow numbers" do
      expect("3way".to_name.key).to eq("3way")
    end

    it "internal plurals" do
      expect("cards hooks label foos".to_name.key).to eq("card_hook_label_foo")
    end

    it "should handle html entities" do
      # This no longer takes off the s, is singularize broken now?
      expect("Jean-fran&ccedil;ois Noubel".to_name.key).to(
        eq("jean_françoi_noubel")
      )
    end
  end

  describe "#url_key" do
    cardnames = ["GrassCommons.org", "Oh you @##", "Alice's Restaurant!",
                 "PB &amp; J", "Mañana"].map(&:to_name)

    cardnames.each do |cardname|
      it "should have the same key as the name" do
        k = cardname.key
        k2 = cardname.url_key
        # warn "cn tok #{cardname.inspect}, #{k.inspect}, #{k2.inspect}"
        expect(k).to eq(k2.to_name.key)
      end
    end
  end

  describe "#valid" do
    it "accepts valid names" do
      expect("this+THAT".to_name).to be_valid
      expect("THE*ONE*AND$!ONLY".to_name).to be_valid
    end

    it "rejects invalid names" do
      # 'Tes~sd'.to_name.should_not be_valid
      expect("TEST/DDER".to_name).not_to be_valid
    end

    it "rejects long names" do
      card = Card.new
      card.name = "1" * 256
      expect(card).not_to be_valid
    end
  end

  describe "#left_name" do
    it "returns nil for non junction" do
      expect("a".to_name.left_name).to eq(nil)
    end

    it "returns parent for parent" do
      expect("a+b+c+d".to_name.left_name).to eq("a+b+c")
    end
  end

  describe "#tag_name" do
    it "returns last part of plus card" do
      expect("a+b+c".to_name.tag).to eq("c")
    end

    it "returns name of simple card" do
      expect("a".to_name.tag).to eq("a")
    end
  end

  describe "#safe_key" do
    it "subs pluses & stars" do
      expect("Alpha?+*be-ta".to_name.safe_key).to eq("alpha-Xbe_tum")
    end
  end

  describe "#replace_part" do
    it "replaces first name part" do
      expect("a+b".to_name.replace_part("a", "x").to_s).to eq("x+b")
    end
    it "replaces second name part" do
      expect("a+b".to_name.replace_part("b", "x").to_s).to eq("a+x")
    end
    it "replaces two name parts" do
      expect("a+b+c".to_name.replace_part("a+b", "x").to_s).to eq("x+c")
      expect("a+b+c+d".to_name.replace_part("a+b", "e+f").to_s).to eq("e+f+c+d")
    end
    it "doesn't replace two part tag" do
      expect("a+b+c".to_name.replace_part("b+c", "x").to_s).to eq("a+b+c")
    end
  end

  describe "Cardnames star handling" do
    it "recognizes star cards" do
      expect("*a".to_name.star?).to be_truthy
    end

    it "doesn't recognize star cards with plusses" do
      expect("*a+*b".to_name.star?).to be_falsey
    end

    it "recognizes rstar cards" do
      expect("a+*a".to_name.rstar?).to be_truthy
    end

    it "doesn't recognize star cards as rstar" do
      expect("*a".to_name.rstar?).to be_falsey
    end

    it "doesn't recognize non-star or star left" do
      expect("*a+a".to_name.rstar?).to be_falsey
    end
  end

  describe "trait_name?" do
    it "returns true for content codename" do
      expect("bazoinga+*right+*structure".to_name.trait_name?(:structure)).to(
        be_truthy
      )
    end

    it "handles arrays" do
      structure =
        "bazoinga+*right+*structure".to_name.trait_name?(:structure, :default)
      expect(structure).to be_truthy
    end

    it "returns false for non-template" do
      structure = "bazoinga+*right+nontent".to_name.trait_name?(:structure)
      expect(structure).to be_falsey
    end
  end

  describe "#to_absolute" do
    it "handles _self, _whole, _" do
      expect("_self".to_name.to_absolute("foo")).to eq("foo")
      expect("_whole".to_name.to_absolute("foo")).to eq("foo")
      expect("_".to_name.to_absolute("foo")).to eq("foo")
    end

    it "handles _left" do
      expect("_left+Z".to_name.to_absolute("A+B+C")).to eq("A+B+Z")
    end

    it "handles white space" do
      expect("_left + Z".to_name.to_absolute("A+B+C")).to eq("A+B+Z")
    end

    it "handles _right" do
      expect("_right+bang".to_name.to_absolute("nutter+butter")).to(
        eq("butter+bang")
      )
      expect("C+_right".to_name.to_absolute("B+A")).to eq("C+A")
    end

    it "handles leading +" do
      expect("+bug".to_name.to_absolute("hum")).to eq("hum+bug")
    end

    it "handles trailing +" do
      expect("bug+".to_name.to_absolute("tracks")).to eq("bug+tracks")
    end

    it "handles _(numbers)" do
      expect("_1".to_name.to_absolute("A+B+C")).to eq("A")
      expect("_1+_2".to_name.to_absolute("A+B+C")).to eq("A+B")
      expect("_2+_3".to_name.to_absolute("A+B+C")).to eq("B+C")
    end

    it "handles _LLR etc" do
      expect("_R".to_name.to_absolute("A+B+C+D+E")).to    eq("E")
      expect("_L".to_name.to_absolute("A+B+C+D+E")).to    eq("A+B+C+D")
      expect("_LR".to_name.to_absolute("A+B+C+D+E")).to   eq("D")
      expect("_LL".to_name.to_absolute("A+B+C+D+E")).to   eq("A+B+C")
      expect("_LLR".to_name.to_absolute("A+B+C+D+E")).to  eq("C")
      expect("_LLL".to_name.to_absolute("A+B+C+D+E")).to  eq("A+B")
      expect("_LLLR".to_name.to_absolute("A+B+C+D+E")).to eq("B")
      expect("_LLLL".to_name.to_absolute("A+B+C+D+E")).to eq("A")
    end

    context "mismatched requests" do
      it "returns _self for _left or _right on simple cards" do
        expect("_left+Z".to_name.to_absolute("A")).to eq("A+Z")
        expect("_right+Z".to_name.to_absolute("A")).to eq("A+Z")
      end

      it "handles bogus numbers" do
        expect("_1".to_name.to_absolute("A")).to eq("A")
        expect("_1+_2".to_name.to_absolute("A")).to eq("A+A")
        expect("_2+_3".to_name.to_absolute("A")).to eq("A+A")
      end

      it "handles bogus _llr requests" do
        expect("_R".to_name.to_absolute("A")).to eq("A")
        expect("_L".to_name.to_absolute("A")).to eq("A")
        expect("_LR".to_name.to_absolute("A")).to eq("A")
        expect("_LL".to_name.to_absolute("A")).to eq("A")
        expect("_LLR".to_name.to_absolute("A")).to eq("A")
        expect("_LLL".to_name.to_absolute("A")).to eq("A")
        expect("_LLLR".to_name.to_absolute("A")).to eq("A")
        expect("_LLLL".to_name.to_absolute("A")).to eq("A")
      end
    end

    it "does session user substitution" do
      expect("_user".to_name.to_absolute("A")).to eq(Card::Auth.current.name)
      Card::Auth.as_bot do
        expect("_user".to_name.to_absolute("A")).to eq(Card::Auth.current.name)
      end
    end
  end

  describe "#to_show" do
    it "ignores ignorables" do
      expect("you+awe".to_name.to_show("you")).to eq("+awe")
      # HMMM..... what should this do?
      expect("me+you+awe".to_name.to_show("you")).to eq("me+awe")
      expect("me+you+awe".to_name.to_show("me")).to eq("+you+awe")
      expect("me+you+awe".to_name.to_show("me", "you")).to eq("+awe")
      expect("me+you".to_name.to_show("me", "you")).to eq("me+you")
      expect("?a?+awe".to_name.to_show("A")).to eq("+awe")
      expect("+awe".to_name.to_show).to eq("+awe")
    end
  end

  describe "part creation" do
    it "creates parts" do
      Card::Auth.as_bot do
        Card.create name: "left+right"
      end
      expect(Card.fetch("right")).to be_truthy
    end
  end
end
