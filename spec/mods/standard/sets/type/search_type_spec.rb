# -*- encoding : utf-8 -*-

describe Card::Set::Type::SearchType do
  it "should wrap search items with correct view class" do
    Card.create :type=>'Search', :name=>'Asearch', :content=>%{{"type":"User"}}
    c=render_content("{{Asearch|core;item:name}}")
    c.should match('search-result-item item-name')
    render_content("{{Asearch|core}}"          ).scan('search-result-item item-closed').size.should == 10
    render_content("{{Asearch|core;item:open}}").scan('search-result-item item-open'  ).size.should == 10
    render_content("{{Asearch|core|titled}}"   ).scan('search-result-item item-titled').size.should == 10
  end

  it "should handle returning 'count'" do
    render_card(:core, :type=>'Search', :content=>%{{ "type":"User", "return":"count"}}).should == '10'
  end
  
  it "should pass item args correctly" do
    Card.create!(
      :name=>'Pointer2Searches', 
      :type_id=>Card::PointerID, 
      :content=>"[[Layout+*type+by name]]\n[[PlainText+*type+by name]]"
    )
    r = render_content "{{Pointer2Searches|core|closed|hide:menu}}"
    r.scan('"view":"link"').size.should == 0
    r.scan('item-closed').size.should == 2 #there are two of each
  end
end
