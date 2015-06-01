# -*- encoding : utf-8 -*-

describe Card::Set::All::Collection do
  describe "#item_names" do
    it "returns item for each line of basic content" do
      expect(Card.new( :name=>"foo", :content => "X\nY" ).item_names).to eq(["X","Y"])
    end

    it "returns list of card names for search" do
      card = Card.new( :name=>"foo", :type=>"Search", :content => %[{"name":"Z"}])
      expect(card.item_names).to eq(["Z"])
    end

    it "handles searches relative to context card" do
      # note: A refers to 'Z'
      expect(Card.new(:name=>"foo", :type=>"Search", :content => %[{"referred_to_by":"_self"}]).item_names( :context=>'A' )).to eq(["Z"])
    end
  end

  describe "#extended_list" do
    it "returns item's content for pointer setting" do
      c = Card.new(:name=>"foo", :type=>"Pointer", :content => "[[Z]]")
      expect(c.extended_list).to eq(["I'm here to be referenced to"])
    end
  end

  describe "#extended_item_cards" do
    it "returns the 'leaf cards' of a tree of pointer cards" do
      Card::Auth.as_bot do
        Card.create!(:name=>"node", :type=>"Pointer", :content=>"[[Z]]")
      end
      c = Card.new(:name=>"foo", :type=>"Pointer", :content => "[[node]]\n[[A]]")
      expect(c.extended_item_cards).to eq([Card.fetch("Z"),Card.fetch("A")],)
    end
  end

  describe "#extended_item_contents" do
    it "returns the content of the 'leaf cards' of a tree of pointer cards" do
      Card::Auth.as_bot do
        Card.create!(:name=>"node", :type=>"Pointer", :content=>"[[Z]]")
      end
      c = Card.new(:name=>"foo", :type=>"Pointer", :content =>  "[[node]]\n[[T]]")
      expect(c.extended_item_contents).to eq(["I'm here to be referenced to", "Theta"])
    end
  end

  describe "#contextual_content" do

    it "processes inclusions relative to context card" do
      context_card = Card["A"] # refers to 'Z'
      c = Card.new(:name=>"foo", :content => "{{_self+B|core}}")
      expect(c.contextual_content( context_card )).to eq("AlphaBeta")
    end

    it "returns content even when context card is hard templated" do #why the heck is this good?  -efm
      context_card = Card["A"] # refers to 'Z'

      Card::Auth.as_bot do
        Card.create! :name => "A+*self+*structure", :content => "Banana"
      end
      c = Card.new( :name => "foo", :content => "{{_self+B|core}}" )
      expect(c.contextual_content( context_card )).to eq("AlphaBeta")
    end
  end

  describe 'tabs view' do
    it 'renders tab panel' do
      tabs = render_card :tabs, :content=>"[[A]]\n[[B]]\n[C]", :type=>'pointer'
      assert_view_select tabs, 'div[role=tabpanel]' do
        assert_select 'li > a[data-toggle=tab]'
      end
    end

    it 'loads only the first tab pane' do
      tabs = render_card :tabs, :content=>"[[A]]\n[[B]]\n[C]", :type=>'pointer'
      assert_view_select tabs, 'div[role=tabpanel]' do
        assert_select 'div.tab-pane#tempo_rary-a  span.card-title', 'A'
        assert_select 'li > a.load[data-toggle=tab][href=#tempo_rary-b]'
        assert_select 'div.tab-pane#tempo_rary-b', ''
      end
    end

    it 'handles item views' do
      tabs = render_content '{{Fruit+*type+*create|tabs|name}}'
      assert_view_select tabs, 'div[role=tabpanel]' do
        assert_select 'div.tab-pane#fruit-Xtype-Xcreate-anyone', 'Anyone'
      end
    end

    it 'handles item params' do
      tabs = render_content '{{Fruit+*type+*create|tabs|name;structure:Home}}'
      path = "/Anyone?#{ {:view=>:name,:slot=>{:structure=>'Home'}}.to_param}"
      assert_view_select tabs, 'div[role=tabpanel]' do
        assert_select "li > a[data-toggle=tab][data-url=#{path}]"
      end
    end

  end
end
