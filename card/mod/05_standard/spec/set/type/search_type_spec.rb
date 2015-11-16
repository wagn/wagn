# -*- encoding : utf-8 -*-

describe Card::Set::Type::SearchType do
  it "wraps search items with correct view class" do
    Card.create type: 'Search', name: 'Asearch', content: %{{"type":"User"}}
    c=render_content("{{Asearch|core;item:name}}")
    expect(c).to match('search-result-item item-name')
    expect(render_content("{{Asearch|core}}"          ).scan('search-result-item item-closed').size).to eq(14)
    expect(render_content("{{Asearch|core;item:open}}").scan('search-result-item item-open'  ).size).to eq(14)
    expect(render_content("{{Asearch|core|titled}}"   ).scan('search-result-item item-titled').size).to eq(14)
  end

  it "handles returning 'count'" do
    expect(render_card(:core, type: 'Search', content: %{{ "type":"User", "return":"count"}})).to eq('14')
  end

  it "passes item args correctly" do
    Card.create!(
      name: 'Pointer2Searches',
      type_id: Card::PointerID,
      content: "[[Layout+*type+by name]]\n[[PlainText+*type+by name]]"
    )
    r = render_content "{{Pointer2Searches|core|closed|hide:menu}}"
    expect(r.scan('"view":"link"').size).to eq(0)
    expect(r.scan('item-closed').size).to eq(2) #there are two of each
  end

  it 'handles type update from pointer' do
    pointer_card = Card.create!(
        name: "PointerToSearches",
        type_id: Card::PointerID,
    )

    pointer_card.update_attributes! type_id: Card::SearchTypeID,content: %{{"type":"User"}}
    expect(pointer_card.content).to eq(%{{"type":"User"}})
  end

  context 'with right plus array' do
    it 'render the card list and paging correctly' do
      Card.create! name: 'Samsung'
      Card.create! name: 'Samsung+tag'
      Card.create! name: 'Samsung+source'
      Card.create! name: 'Apple'
      Card.create! name: 'Apple+tag'
      Card.create! name: 'Apple+source'
      Card.create! name: 'HTC'
      Card.create! name: 'HTC+tag'
      Card.create! name: 'HTC+source'
      search_card = Card.create!(
        name: 'search_with_right_plus',
        type_id: Card::SearchTypeID,
        content: %{
            {
              "right_plus":{
                "name":["in","tag","source"]
              },
              "limit":1
            }
        }
      )
      html = search_card.format.render_open
      expect(html).to have_tag('ul', with: { class: 'pagination paging' }) do
        with_tag 'a', text: '1'
        with_tag 'a', text: '2'
        with_tag 'a', text: '3'
      end
      expect(html).to have_tag('div', with: { class: 'search-result-list' }) do
        with_tag 'div', with: { id: 'Apple' }
      end
    end
  end

  context 'references' do
    before do
      Card.create type: 'Search', name: 'search with references', content: '{"name":"Y"}'
    end
    subject do
      Card['search with references']
    end

    it 'updates query if referee changed' do
      Card['Y'].update_attributes! name: 'YYY', update_referencers: true
      expect(subject.content).to eq '{"name":"YYY"}'
    end

  end
end
