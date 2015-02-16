# -*- encoding : utf-8 -*-

describe Card::Set::Type::SearchType do
  it "should wrap search items with correct view class" do
    Card.create :type=>'Search', :name=>'Asearch', :content=>%{{"type":"User"}}
    c=render_content("{{Asearch|core;item:name}}")
    expect(c).to match('search-result-item item-name')
    expect(render_content("{{Asearch|core}}"          ).scan('search-result-item item-closed').size).to eq(14)
    expect(render_content("{{Asearch|core;item:open}}").scan('search-result-item item-open'  ).size).to eq(14)
    expect(render_content("{{Asearch|core|titled}}"   ).scan('search-result-item item-titled').size).to eq(14)
  end

  it "should handle returning 'count'" do
    expect(render_card(:core, :type=>'Search', :content=>%{{ "type":"User", "return":"count"}})).to eq('14')
  end
  
  it "should pass item args correctly" do
    Card.create!(
      :name=>'Pointer2Searches', 
      :type_id=>Card::PointerID, 
      :content=>"[[Layout+*type+by name]]\n[[PlainText+*type+by name]]"
    )
    r = render_content "{{Pointer2Searches|core|closed|hide:menu}}"
    expect(r.scan('"view":"link"').size).to eq(0)
    expect(r.scan('item-closed').size).to eq(2) #there are two of each
  end
end
