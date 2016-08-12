# -*- encoding : utf-8 -*-

describe Card::Set::All::Collection do
  describe "#item_names" do
    subject do
      item_names_args = @context ? { context: @context } : {}
      Card.new(@args).item_names(item_names_args)
    end
    it "returns item for each line of basic content" do
      @args = { name: "foo", content: "X\nY" }
      is_expected.to eq(%w(X Y))
    end

    it "returns list of card names for search" do
      @args = { name: "foo", type: "Search", content: '{"name":"Z"}' }
      is_expected.to eq(["Z"])
    end

    it "handles searches relative to context card" do
      # note: A refers to 'Z'
      @context = "A"
      @args = { name: "foo", type: "Search",
                content: '{"referred_to_by":"_self"}' }
      is_expected.to eq(["Z"])
    end
  end

  describe "#extended_list" do
    it "returns item's content for pointer setting" do
      c = Card.new(name: "foo", type: "Pointer", content: "[[Z]]")
      expect(c.extended_list).to eq(["I'm here to be referenced to"])
    end
  end

  describe "#extended_item_cards" do
    it "returns the 'leaf cards' of a tree of pointer cards" do
      Card::Auth.as_bot do
        Card.create!(name: "node", type: "Pointer", content: "[[Z]]")
      end
      c = Card.new(name: "foo", type: "Pointer", content: "[[node]]\n[[A]]")
      expect(c.extended_item_cards).to eq([Card.fetch("Z"), Card.fetch("A")])
    end
  end

  describe "#extended_item_contents" do
    it "returns the content of the 'leaf cards' of a tree of pointer cards" do
      Card::Auth.as_bot do
        Card.create!(name: "node", type: "Pointer", content: "[[Z]]")
      end
      c = Card.new(name: "foo", type: "Pointer", content:  "[[node]]\n[[T]]")
      expect(c.extended_item_contents)
        .to eq(["I'm here to be referenced to", "Theta"])
    end
  end

  describe "#contextual_content" do
    it "processes nests relative to context card" do
      context_card = Card["A"] # refers to 'Z'
      c = Card.new(name: "foo", content: "{{_self+B|core}}")
      expect(c.contextual_content(context_card)).to eq("AlphaBeta")
    end

    # why the heck is this good?  -efm
    it "returns content even when context card is hard templated" do
      context_card = Card["A"] # refers to 'Z'

      Card::Auth.as_bot do
        Card.create! name: "A+*self+*structure", content: "Banana"
      end
      c = Card.new name: "foo", content: "{{_self+B|core}}"
      expect(c.contextual_content(context_card)).to eq("AlphaBeta")
    end
  end

  describe "#map_nests" do
    before do
      Card::Auth.as_bot do
        @list = Card.create!(
          name: "mixed list",
          content: "[[A]]\n{{B}}\n[[C|link C]]\n{{D|name;title:nest D}}"
        )
      end
    end
    it "handles links and nest arguments" do
      result = @list.format.map_references_with_args do |name, args|
        [name, args]
      end
      expect(result).to eq [
        ["A", { view: :closed }],
        ["B", { view: :closed, inc_name: "B", inc_syntax: "B" }],
        ["C", { view: :closed, title: "link C" }],
        ["D", { view: "name", title: "nest D", inc_name: "D",
                inc_syntax: "D|name;title:nest D" }]
      ]
    end
  end

  describe "tabs view" do
    it "renders tab panel" do
      tabs = render_card :tabs, content: "[[A]]\n[[B]]\n[[C]]", type: "pointer"
      assert_view_select tabs, "div[role=tabpanel]" do
        assert_select "li > a[data-toggle=tab]"
      end
    end

    it "loads only the first tab pane" do
      tabs = render_card :tabs, content: "[[A]]\n[[B]]\n[[C]]", type: "pointer"
      assert_view_select tabs, "div[role=tabpanel]" do
        assert_select "div.tab-pane#tempo_rary-a  .card-slot#A"
        assert_select 'li > a.load[data-toggle=tab][href="#tempo_rary-b"]'
        assert_select "div.tab-pane#tempo_rary-b", ""
      end
    end

    it "handles relative names" do
      Card::Auth.as_bot do
        Card.create! name: "G", content: "[[+B]]", type: "pointer",
                     subcards: { "+B" => "GammaBeta" }
      end
      tabs = Card.fetch("G").format.render_tabs
      assert_view_select tabs, "div[role=tabpanel]" do
        assert_select "div.tab-pane#g-g-b .card-content", "GammaBeta"
      end
    end

    it "handles item views" do
      tabs = render_content "{{Fruit+*type+*create|tabs|name}}"
      assert_view_select tabs, "div[role=tabpanel]" do
        assert_select "div.tab-pane#fruit-Xtype-Xcreate-anyone", "Anyone"
      end
    end

    it "handles item params" do
      tabs = render_content "{{Fruit+*type+*create|tabs|name;structure:Home}}"
      params = { slot: { structure: "Home" }, view: :name }.to_param
      path = "/Anyone?#{params}"
      assert_view_select tabs, "div[role=tabpanel]" do
        assert_select %(li > a[data-toggle="tab"][data-url="#{path}"])
      end
    end
    it "handles nests as items" do
      tabs = render_card :tabs, name: "tab_test", type_id: Card::PlainTextID,
                                content: "{{A|type;title:my tab title}}"
      assert_view_select tabs, "div[role=tabpanel]" do
        assert_select 'li > a[data-toggle=tab][href="#tab_test-my_tab_title"]',
                      "my tab title"
        assert_select "div.tab-pane#tab_test-my_tab_title", "Basic"
      end
    end

    it "works with search cards" do
      Card.create type: "Search", name: "Asearch", content: '{"type":"User"}'
      tabs = render_content("{{Asearch|tabs;item:name}}")
      assert_view_select tabs, "div[role=tabpanel]" do
        assert_select(
          'li > a[data-toggle=tab][href="#asearch-joe_admin"] span.card-title',
          "Joe Admin"
        )
      end
    end
  end
end
