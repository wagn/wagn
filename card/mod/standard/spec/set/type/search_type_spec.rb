# -*- encoding : utf-8 -*-

describe Card::Set::Type::SearchType do
  it "wraps search items with correct view class" do
    Card.create type: "Search", name: "Asearch", content: %({"type":"User"})
    c = render_content("{{Asearch|core|name}}")
    expect(c).to match("search-result-item item-name")
    expect(render_content("{{Asearch|core}}")
             .scan("search-result-item item-closed").size).to eq(14)
    expect(render_content("{{Asearch|core|open}}")
             .scan("search-result-item item-open").size).to eq(14)
    expect(render_content("{{Asearch|core|titled}}")
             .scan("search-result-item item-titled").size).to eq(14)
  end

  it "handles returning 'count'" do
    rendered = render_card(:core,
                           type: "Search",
                           content: %({ "type":"User", "return":"count"}))
    expect(rendered).to eq("14")
  end

  it "passes item args correctly" do
    Card.create!(
      name: "Pointer2Searches",
      type_id: Card::PointerID,
      content: "[[Layout+*type+by name]]\n[[PlainText+*type+by name]]"
    )
    r = render_content "{{Pointer2Searches|core|closed|hide:menu}}"
    expect(r.scan('"view":"link"').size).to eq(0)
    expect(r.scan("item-closed").size).to eq(2) # there are two of each
  end

  it "handles type update from pointer" do
    pointer_card = Card.create!(
      name: "PointerToSearches",
      type_id: Card::PointerID
    )

    pointer_card.update_attributes! type_id: Card::SearchTypeID,
                                    content: %({"type":"User"})
    expect(pointer_card.content).to eq(%({"type":"User"}))
  end

  context "references" do
    before do
      Card.create type: "Search", name: "search with references",
                  content: '{"name":"Y"}'
    end
    subject do
      Card["search with references"]
    end

    it "updates query if referee changed" do
      Card["Y"].update_attributes! name: "YYY", update_referers: true
      expect(subject.content).to eq '{"name":"YYY"}'
    end
  end
  describe "rss format" do
    it "render rss without errors" do
      search_card = Card.create type: "Search", name: "Asearch",
                                content: %({"id":"1"})
      rss = search_card.format(:rss).render_feed
      expect(rss).to have_tag("title", text: "Wagn Bot")
    end
  end

  describe "csv format" do
    describe "view :content" do
      subject do
        render_view :content, { name: "Book+*type+by name" },
                    format: :csv
      end

      it "has title row with nest names" do
        is_expected.to include "AUTHOR,ILLUSTRATOR"
      end

      it "has nests contents" do
        create "Guide",
               type: "Book",
               subfields: { "author" => "Hitchhiker",
                            "illustrator" => "Galaxy" }
        is_expected.to include "Hitchhiker,Galaxy"
      end
    end

    describe "view :nested_fields" do
      subject do
        render_view :nested_fields, { name: "Book+*type+by name" },
                    format: :csv
      end

      it "has title row item name and field names" do
        is_expected.to include "NAME,AUTHOR,ILLUSTRATOR"
      end

      it "has field contents" do
        create "Guide",
               type: "Book",
               subfields: { "author" => "Hitchhiker",
                            "illustrator" => "Galaxy" }
        is_expected.to include "Guide,Hitchhiker,Galaxy"
      end
    end
  end
end
