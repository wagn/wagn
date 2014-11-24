# -*- encoding : utf-8 -*-

describe Card::Chunk::Link do

  it "should handle unknown cards" do
    expect(render_content('[[Nixon]]')).to eq('<a class="wanted-card" href="/Nixon">Nixon</a>')
  end

  it 'should handle known cards' do
    expect(render_content("[[A]]")).to eq('<a class="known-card" href="/A">A</a>')
  end
  
  it 'should handle custom text' do
    expect(render_content('[[Baines|Lyndon]]')).to eq('<a class="wanted-card" href="/Baines">Lyndon</a>')
  end

  it "should handle relative names" do
    @card = Card.new :name=>'Kennedy'
    expect(render_content('[[+Monroe]]'     )).to eq('<a class="wanted-card" href="/Kennedy+Monroe">Kennedy+Monroe</a>')
    expect(render_content('[[_self+Exner]]' )).to eq('<a class="wanted-card" href="/Kennedy+Exner">Kennedy+Exner</a>')
    expect(render_content('[[Onassis+]]'    )).to eq('<a class="wanted-card" href="/Onassis+Kennedy">Onassis+Kennedy</a>')
  end

  it "should handle relative names in context" do
    @card = Card.new :name=>'Kennedy'
    format_args = { :context_names => [ 'Kennedy'.to_name ] }
    expect(render_content('[[+Monroe]]'    , format_args )).to eq('<a class="wanted-card" href="/Kennedy+Monroe">+Monroe</a>')
    expect(render_content('[[_self+Exner]]', format_args )).to eq('<a class="wanted-card" href="/Kennedy+Exner">+Exner</a>')
    expect(render_content('[[Onassis+]]'   , format_args )).to eq('<a class="wanted-card" href="/Onassis+Kennedy">Onassis</a>')
  end

  it "should handle relative urls" do
    expect(render_content('[[/recent]]')).to eq('<a class="internal-link" href="/recent">/recent</a>')
  end

  it "should handle absolute urls" do
    expect(render_content('[[http://google.com]]')).to eq('<a class="external-link" href="http://google.com">http://google.com</a>')
  end

  it "should escape spaces in cardnames with %20 (not +)" do
    expect(render_content('[[Marie "Mad Dog" Deatherage|Marie]]')).to eq(
      '<a class="wanted-card" href="/Marie_Mad_Dog_Deatherage?card%5Bname%5D=Marie+%22Mad+Dog%22+Deatherage">Marie</a>'
    )
  end

  it "should not escape content outside of link" do
    expect(render_content('wgw&nbsp; [[http://www.google.com|google]] &nbsp;  <br>')).to eq( 
      "wgw&nbsp; <a class=\"external-link\" href=\"http://www.google.com\">google</a> &nbsp;  <br>"
    )
  end
  
  it "should handle inclusions in link text" do
    expect(render_content('[[linkies|{{namies|name}}]]')).to eq('<a class="wanted-card" href="/linkies">namies</a>')
  end
  
  it "should handle dot (.) in missing cardlink" do
    expect(render_content("[[Wagn 1.10.12]]")).to eq('<a class="wanted-card" href="/Wagn_1_10_12?card%5Bname%5D=Wagn+1.10.12">Wagn 1.10.12</a>')
  end

end

