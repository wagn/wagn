# -*- encoding : utf-8 -*-
require 'wagn/pack_spec_helper'

describe Card::Chunk::Link do

  it "should handle unknown cards" do
    render_content('[[Nixon]]').should == '<a class="wanted-card" href="/Nixon">Nixon</a>'
  end

  it 'should handle known cards' do
    render_content("[[A]]").should=='<a class="known-card" href="/A">A</a>'
  end
  
  it 'should handle custom text' do
    render_content('[[Baines|Lyndon]]').should == '<a class="wanted-card" href="/Baines">Lyndon</a>'
  end

  it "should handle relative names" do
    @card = Card.new :name=>'Kennedy'
    render_content('[[+Monroe]]'     ).should == '<a class="wanted-card" href="/Kennedy%2BMonroe">Kennedy+Monroe</a>'
    render_content('[[_self+Exner]]' ).should == '<a class="wanted-card" href="/Kennedy%2BExner">Kennedy+Exner</a>'
    render_content('[[Onassis+]]'    ).should == '<a class="wanted-card" href="/Onassis%2BKennedy">Onassis+Kennedy</a>'
  end

  it "should handle relative names in context" do
    @card = Card.new :name=>'Kennedy'
    format_args = { :context_names => [ 'Kennedy'.to_name ] }
    render_content('[[+Monroe]]'    , format_args ).should == '<a class="wanted-card" href="/Kennedy%2BMonroe">+Monroe</a>'
    render_content('[[_self+Exner]]', format_args ).should == '<a class="wanted-card" href="/Kennedy%2BExner">+Exner</a>'
    render_content('[[Onassis+]]'   , format_args ).should == '<a class="wanted-card" href="/Onassis%2BKennedy">Onassis</a>'
  end

  it "should handle relative urls" do
    render_content('[[/recent]]').should == '<a class="internal-link" href="/recent">/recent</a>'
  end

  it "should handle absolute urls" do
    render_content('[[http://google.com]]').should == '<a class="external-link" href="http://google.com">http://google.com</a>'
  end

  it "should escape spaces in cardnames with %20 (not +)" do
    render_content('[[Marie "Mad Dog" Deatherage|Marie]]').should == '<a class="wanted-card" href="/Marie%20%22Mad%20Dog%22%20Deatherage">Marie</a>'
  end

  it "should not escape content outside of link" do
    render_content('wgw&nbsp; [[http://www.google.com|google]] &nbsp;  <br>').should == 
      "wgw&nbsp; <a class=\"external-link\" href=\"http://www.google.com\">google</a> &nbsp;  <br>"
  end
  
  it "should handle inclusions in link text" do
    render_content('[[linkies|{{namies|name}}]]').should == '<a class="wanted-card" href="/linkies">namies</a>'
  end
  
  it "should handle dot (.) in missing cardlink" do
    render_content("[[Wagn 1.10.12]]").should=='<a class="wanted-card" href="/Wagn%201%2E10%2E12">Wagn 1.10.12</a>'
  end

end

