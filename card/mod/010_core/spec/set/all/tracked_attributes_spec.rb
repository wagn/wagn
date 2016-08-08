# -*- encoding : utf-8 -*-

module RenameMethods
  def name_invariant_attributes card
    {
      content:     card.content,
      # updater_id:  card.updater_id,
      # revisions:   card.actions.count,
      referers: card.referers.map(&:name).sort,
      referees:    card.referees.map(&:name).sort,
      descendants:  card.descendants.map(&:id).sort
    }
  end

  def assert_rename card, new_name
    attrs_before = name_invariant_attributes(card)
    actions_count_before = card.actions.count
    card.name = new_name
    card.update_referers = true
    card.save!
    expect(card.actions.count).to eq(actions_count_before + 1)
    assert_equal attrs_before, name_invariant_attributes(card)
    assert_equal new_name, card.name
    assert Card[new_name]
  end

  def card name
    Card[name].refresh || raise("Couldn't find card named #{name}")
  end
end

describe Card::Set::All::TrackedAttributes do
  include RenameMethods

  describe "set_name" do
    it "should handle case variants" do
      @c = Card.create! name: "chump"
      expect(@c.name).to eq("chump")
      @c.name = "Chump"
      @c.save!
      expect(@c.name).to eq("Chump")
    end

    it "should handle changing from plus card to simple" do
      c = Card.create! name: "four+five"
      c.name = "nine"
      c.save!
      expect(c.name).to eq("nine")
      expect(c.left_id).to eq(nil)
      expect(c.right_id).to eq(nil)
    end

    # FIXME: - following tests more about fetch than set_name.
    # this spec still needs lots of cleanup

    it "test fetch with new when present" do
      Card.create!(name: "Carrots")
      cards_should_be_added 0 do
        c = Card.fetch "Carrots", new: {}
        c.save
        expect(c).to be_instance_of(Card)
        expect(Card.fetch("Carrots")).to be_instance_of(Card)
      end
    end

    it "test_simple" do
      cards_should_be_added 1 do
        expect(Card["Boo!"]).to be_nil
        expect(Card.create(name: "Boo!")).to be_instance_of(Card)
        expect(Card["Boo!"]).to be_instance_of(Card)
      end
    end

    it "test fetch with new when not present" do
      cards_should_be_added 1 do
        c = Card.fetch("Tomatoes", new: {})
        c.save
        expect(c).to be_instance_of(Card)
        expect(Card.fetch("Tomatoes")).to be_instance_of(Card)
      end
    end

    it "test_create_junction" do
      cards_should_be_added 3 do
        pearch = Card.create name: "Peach+Pear", content: "juicy"
        expect(pearch).to be_instance_of(Card)
      end
      expect(Card["Peach"]).to be_instance_of(Card)
      expect(Card["Pear"]).to be_instance_of(Card)
      assert_equal "juicy", Card["Peach+Pear"].content
    end

  private

    def cards_should_be_added number
      number += Card.all.count
      yield
      expect(Card.all.count).to eq(number)
    end
  end

  describe "renaming" do
    # FIXME: these tests are TOO SLOW!
    # 8s against server, 12s from command line.
    # not sure if it's the card creation or the actual renaming process.
    # Card#save needs optimized in general.
    # Can't we just move this data to fixtures?

    it "renaming plus card to its own child" do
      assert_rename card("A+B"), "A+B+T"
    end

    it "clears cache for old name" do
      assert_rename Card["Menu"], "manure"
      expect(Card["Menu"]).to be_nil
    end

    it "wipes old references by default" do
      c = Card["Menu"]
      c.name = "manure"
      c.save!
      expect(Card["manure"].references_in.size).to eq(0)
    end

    it "picks up new references" do
      Card.create name: "kinds of poop", content: "[[manure]]"
      assert_rename Card["Menu"], "manure"
      expect(Card["manure"].references_in.size).to eq(2)
    end

    it "handles name variants" do
      assert_rename card("B"), "b"
    end

    it "handles plus cards renamed to simple" do
      assert_rename card("A+B"), "K"
    end

    it "handles flipped parts" do
      assert_rename card("A+B"), "B+A"
    end

    it "test_should_error_card_exists" do
      @t = card "T"
      @t.name = "A+B"
      assert !@t.save, "save should fail"
      assert @t.errors[:name], "should have errors on key"
    end

    it "test_used_as_tag" do
      @b = card "B"
      @b.name = "A+D"
      @b.save
      assert @b.errors[:name]
    end

    it "test_update_descendants" do
      old_names = %w(One+Two One+Two+Three Four+One Four+One+Five)
      new_names = %w(Uno+Two Uno+Two+Three Four+Uno Four+Uno+Five)
      card_list = old_names.map { |name| Card[name] }

      assert_equal old_names, card_list.map(&:name)
      Card["One"].update_attributes! name: "Uno"
      assert_equal new_names, card_list.map(&:reload).map(&:name)
    end

    it "test_should_error_invalid_name" do
      @t = card "T"
      @t.name = "YT_o~Yo"
      @t.save
      assert @t.errors[:name]
    end

    it "test_simple_to_simple" do
      assert_rename card("A"), "Alephant"
    end

    it "test_simple_to_junction_with_create" do
      assert_rename card("T"), "C+J"
    end

    it "test_reset_key" do
      c = Card["Basic Card"]
      c.name = "banana card"
      c.save!
      expect(c.key).to eq("banana_card")
      expect(Card["Banana Card"]).not_to be_nil
    end

    it "test_rename_should_not_fail_when_updating_inaccessible_referer" do
      Card.create! name: "Joe Card", content: "Whattup"
      Card::Auth.as "joe_admin" do
        Card.create! name: "Admin Card", content: "[[Joe Card]]"
      end
      c = Card["Joe Card"]
      c.update_attributes! name: "Card of Joe", update_referers: true
      assert_equal "[[Card of Joe]]", Card["Admin Card"].content
    end

    it "test_rename_should_update_structured_referer" do
      Card::Auth.as_bot do
        c = Card.create! name: "Pit"
        Card.create! name: "Orange", type: "Fruit", content: "[[Pit]]"
        Card.create! name: "Fruit+*type+*structure", content: "this [[Pit]]"

        assert_equal "this [[Pit]]", Card["Orange"].raw_content
        c.update_attributes! name: "Seed", update_referers: true
        assert_equal "this [[Seed]]", Card["Orange"].raw_content
      end
    end

    it "should handle plus cards that have children" do
      Card::Auth.as_bot do
        Card.create name: "a+b+c+d"
        ab = Card["a+b"]
        assert_rename ab, "e+f"
      end
    end

    context "chuck" do
      before do
        Card::Auth.as_bot do
          Card.create! name: "chuck_wagn+chuck"
        end
      end

      it "test_rename_name_substitution" do
        c1 = Card["chuck_wagn+chuck"]
        c2 = Card["chuck"]
        assert_rename c2, "buck"
        assert_equal "chuck_wagn+buck", Card.find(c1.id).name
      end

      it "test_reference_updates_plus_to_simple" do
        c1 = Card::Auth.as_bot do
          Card.create! name: "Huck", content: "[[chuck wagn+chuck]]"
        end
        c2 = Card["chuck_wagn+chuck"]
        assert_rename c2, "schmuck"
        c1 = Card.find(c1.id)
        assert_equal "[[schmuck]]", c1.content
      end
    end

    context "dairy" do
      before do
        Card::Auth.as_bot do
          Card.create! name:    "Dairy",
                       type:    "Cardtype",
                       content: "[[/new/{{_self|name}}|new]]"
        end
      end

      it "test_renaming_card_with_self_link_should_not_hang" do
        c = Card["Dairy"]
        c.name = "Buttah"
        c.update_referers = true
        c.save!
        assert_equal "[[/new/{{_self|name}}|new]]", Card["Buttah"].content
      end

      it "should rename card without updating references" do
        c = Card["Dairy"]
        c.update_attributes name: "Newt", update_referers: false
        assert_equal "[[/new/{{_self|name}}|new]]", Card["Newt"].content
      end
    end

    context "blues" do
      before do
        Card::Auth.as_bot do
          [["Blue", ""],
           ["blue includer 1", "{{Blue}}"],
           ["blue includer 2", "{{blue|closed;other:stuff}}"],
           ["blue linker 1", "[[Blue]]"],
           ["blue linker 2", "[[blue]]"]
          ].each do |name, content|
            Card.create! name: name, content: content
          end
        end
      end

      it "test_updates_nests_when_renaming" do
        c1 = Card["Blue"]
        c2 = Card["blue includer 1"]
        c3 = Card["blue includer 2"]
        c1.update_attributes name: "Red", update_referers: true
        assert_equal "{{Red}}", Card.find(c2.id).content
        # NOTE these attrs pass through a hash stage that may not preserve order
        assert_equal "{{Red|closed;other:stuff}}", Card.find(c3.id).content
      end

      it "test_updates_nests_when_renaming_to_plus" do
        c1 = Card["Blue"]
        c2 = Card["blue includer 1"]
        c1.update_attributes name: "blue includer 1+color",
                             update_referers: true
        assert_equal "{{blue includer 1+color}}", Card.find(c2.id).content
      end

      it "test_reference_updates_on_case_variants" do
        c1 = Card["Blue"]
        c2 = Card["blue linker 1"]
        c3 = Card["blue linker 2"]
        c1.reload.name = "Red"
        c1.update_referers = true
        c1.save!
        assert_equal "[[Red]]", Card.find(c2.id).content
        assert_equal "[[Red]]", Card.find(c3.id).content
      end
    end
  end
end
