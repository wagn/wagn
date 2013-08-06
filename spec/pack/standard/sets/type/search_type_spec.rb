# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card::Set::Type::SearchType do
  it "should wrap search items with correct view class" do
    Card.create :type=>'Search', :name=>'Asearch', :content=>%{{"type":"User"}}
    c=render_content("{{Asearch|core;item:name}}")
    c.should match('search-result-item item-name')
    render_content("{{Asearch|core;item:open}}").should match('search-result-item item-open')
    render_content("{{Asearch|core}}").should match('search-result-item item-closed')
  end

  it "should handle returning 'count'" do
    render_card(:core, :type=>'Search', :content=>%{{ "type":"User", "return":"count"}}).should == '10'
  end
end
