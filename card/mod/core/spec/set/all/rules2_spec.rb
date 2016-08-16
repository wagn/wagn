# -*- encoding : utf-8 -*-

# FIXME: - this seems like a LOT of testing but it doesn't cover a ton of ground
# I think we should move the rendering tests into basic and trim this to about
# a quarter of its current length

describe Card do
  context "when there is a general toc rule of 2" do
    before do
      Card::Auth.as_bot do
        Card.create! name: "Basic+*type+*table of contents", content: "2"
      end
      expect(@c1 = Card["Onne Heading"]).to be
      expect(@c2 = Card["Twwo Heading"]).to be
      expect(@c3 = Card["Three Heading"]).to be
      expect(@c1.type_id).to eq(Card::BasicID)
      expect(@rule_card = @c1.rule_card(:table_of_contents)).to be
    end

    describe ".rule" do
      it "should have a value of 2" do
        expect(@rule_card.content).to eq("2")
        expect(@c1.rule(:table_of_contents)).to eq("2")
      end
    end

    describe "renders with/without toc" do
      it "should not render for 'Onne Heading'" do
        expect(@c1.format.render_open_content).not_to match(/Table of Contents/)
      end
      it "should render for 'Twwo Heading'" do
        expect(@c2.format.render_open_content).to match(/Table of Contents/)
      end
      it "should render for 'Three Heading'" do
        expect(@c3.format.render_open_content).to match(/Table of Contents/)
      end
    end

    describe ".rule_card" do
      it "get the same card without the * and singular" do
        expect(@c1.rule_card(:table_of_contents)).to eq(@rule_card)
      end
    end

    describe ".related_sets" do
      it "has 1 set (right) for a simple card" do
        sets = Card["A"].related_sets.map { |s| s[0] }
        expect(sets).to eq(["A+*right"])
      end
      it "has 2 sets (type, and right) for a cardtype card" do
        sets = Card["Cardtype A"].related_sets.map { |s| s[0] }
        expect(sets).to eq(["Cardtype A+*type", "Cardtype A+*right"])
      end
      # it "should show type plus right sets when they exist" do
      #   Card::Auth.as_bot do
      #     Card.create name: 'Basic+A+*type plus right', content: ''
      #   end
      #   sets = Card['A'].related_sets
      #   sets.should == ['A+*self', 'A+*right', 'Basic+A+*type plus right']
      # end
      # it "should show type plus right sets when they exist, and type" do
      #   Card::Auth.as_bot do
      #     Card.create name: 'Basic+Cardtype A+*type plus right', content: ''
      #   end
      #   sets = Card['Cardtype A'].related_sets
      #   sets.should == ['Cardtype A+*self', 'Cardtype A+*type',
      #     'Cardtype A+*right', 'Basic+Cardtype A+*type plus right']
      # end
      it "is empty for a non-simple card" do
        sets = Card["A+B"].related_sets.map { |s| s[0] }
        expect(sets).to eq([])
      end
    end
    #     # class methods
    #     describe ".default_rule" do
    #       it 'should have default rule' do
    #         Card.default_rule(:table_of_contents).should == '0'
    #       end
    #     end
  end

  context "when I change the general toc setting to 1" do
    before do
      expect(@c1 = Card["Onne Heading"]).to be
      expect(@c2 = Card["Twwo Heading"]).to be
      expect(@c1.type_id).to eq(Card::BasicID)
      expect(@rule_card = @c1.rule_card(:table_of_contents)).to be
      @rule_card.content = "1"
    end

    describe ".rule" do
      it "should have a value of 1" do
        expect(@rule_card.content).to eq("1")
        expect(@c1.rule(:table_of_contents)).to eq("1")
      end
    end

    describe "renders with/without toc" do
      it "should not render toc for 'Onne Heading'" do
        expect(@c1.format.render_open_content).to match(/Table of Contents/)
      end
      it "should render toc for 'Twwo Heading'" do
        expect(@c2.format.render_open_content).to match(/Table of Contents/)
      end
      it "should not render for 'Twwo Heading' when changed to 3" do
        @rule_card.content = "3"
        expect(@c2.rule(:table_of_contents)).to eq("3")
        expect(@c2.format.render_open_content).not_to match(/Table of Contents/)
      end
    end
  end

  context "when I use CardtypeE cards" do
    before do
      Card::Auth.as_bot do
        @c1 = Card.create name: "toc1", type: "CardtypeE",
                          content: Card["Onne Heading"].content
        @c2 = Card.create name: "toc2", type: "CardtypeE",
                          content: Card["Twwo Heading"].content
        @c3 = Card.create name: "toc3", type: "CardtypeE",
                          content: Card["Three Heading"].content
      end
      expect(@c1.type_name).to eq("Cardtype E")
      @rule_card = @c1.rule_card(:table_of_contents)

      expect(@c1).to be
      expect(@c2).to be
      expect(@c3).to be
      expect(@rule_card).to be
    end

    describe ".rule" do
      it "should have a value of 0" do
        expect(@c1.rule(:table_of_contents)).to eq("0")
        expect(@rule_card.content).to eq("0")
      end
    end

    describe "renders without toc" do
      it "should not render for 'Onne Heading'" do
        expect(@c1.format.render_open_content).not_to match(/Table of Contents/)
      end
      it "should render for 'Twwo Heading'" do
        expect(@c2.format.render_open_content).not_to match(/Table of Contents/)
      end
      it "should render for 'Three Heading'" do
        expect(@c3.format.render_open_content).not_to match(/Table of Contents/)
      end
    end

    describe ".rule_card" do
      it "doesn't have a type rule" do
        expect(@rule_card).to be
        expect(@rule_card.name).to eq("*all+*table of contents")
      end

      it "get the same card without the * and singular" do
        expect(@c1.rule_card(:table_of_contents)).to eq(@rule_card)
      end
    end

    #     # class methods
    #     describe ".default_rule" do
    #       it 'should have default rule' do
    #         Card.default_rule(:table_of_contents).should == '0'
    #       end
    #     end
  end

  context "when I create a new rule" do
    before do
      Card::Auth.as_bot do
        Card.create! name: "Basic+*type+*table of contents", content: "2"
        @c1 = Card.create! name: "toc1", type: "CardtypeE",
                           content: Card["Onne Heading"].content
        @c2 = Card.create! name: "toc2", content: Card["Twwo Heading"].content
        @c3 = Card.create! name: "toc3", content: Card["Three Heading"].content
        expect(@c1.type_name).to eq("Cardtype E")
        @rule_card = @c1.rule_card(:table_of_contents)

        expect(@c1).to be
        expect(@c2).to be
        expect(@c3).to be
        expect(@rule_card.name).to eq("*all+*table of contents")
        if (c = Card["CardtypeE+*type+*table of content"])
          c.content = "2"
          c.save!
        else
          Card.create! name: "CardtypeE+*type+*table of content", content: "2"
        end
      end
    end
    it "should take on new setting value" do
      c = Card["toc1"]
      expect(c.rule_card(:table_of_contents).name)
        .to eq("CardtypeE+*type+*table of content")
      expect(c.rule(:table_of_contents)).to eq("2")
    end

    describe "renders with/without toc" do
      it "should not render for 'Onne Heading'" do
        expect(@c1.format.render_open_content).not_to match(/Table of Contents/)
      end
      it "should render for 'Twwo Heading'" do
        expect(@c2.rule(:table_of_contents)).to eq("2")
        expect(@c2.format.render_open_content).to match(/Table of Contents/)
      end
      it "should render for 'Three Heading'" do
        expect(@c3.format.render_open_content).to match(/Table of Contents/)
      end
    end
  end
  # end

  context "when I change the general toc setting to 1" do
    before do
      expect(@c1 = Card["Onne Heading"]).to be
      # FIXME: CardtypeE should inherit from *default => Basic
      # @c2 = Card.create name: 'toc2', type: "CardtypeE",
      #                   content: Card['Twwo Heading'].content
      expect(@c2 = Card["Twwo Heading"]).to be
      expect(@c1.type_id).to eq(Card::BasicID)
      expect(@rule_card = @c1.rule_card(:table_of_contents)).to be
      @rule_card.content = "1"
    end

    describe ".rule" do
      it "should have a value of 1" do
        expect(@rule_card.content).to eq("1")
        expect(@c1.rule(:table_of_contents)).to eq("1")
      end
    end

    describe "renders with/without toc" do
      it "should not render toc for 'Onne Heading'" do
        expect(@c1.format.render_open_content).to match(/Table of Contents/)
      end
      it "should render toc for 'Twwo Heading'" do
        expect(@c2.format.render_open_content).to match(/Table of Contents/)
      end
      it "should not render for 'Twwo Heading' when changed to 3" do
        @rule_card.content = "3"
        expect(@c2.format.render_open_content).not_to match(/Table of Contents/)
      end
    end
  end
end
