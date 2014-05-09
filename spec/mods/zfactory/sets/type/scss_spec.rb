# -*- encoding : utf-8 -*-

load 'spec/mods/zfactory/lib/factory_spec.rb'
load 'spec/mods/zfactory/lib/supplier_spec.rb'

describe Card::Set::Type::Scss do
  let(:css) { '#box { display: block }' }
  let(:compressed_css) {  "#box{display:block}\n" }
  let(:changed_css) { '#box { display: inline }' }
  let(:compressed_changed_css) { "#box{display:inline}\n" }
  before do
    @scss_card = Card[:style_functional]
  end
  
  it 'should highlight code in html' do
    assert_view_select @scss_card.format.render_core, 'div[class=CodeRay]'
  end
  
  it 'should not highlight code in css' do
    @scss_card.format(:format=>:css).render_core.should_not =~ /CodeRay/
  end
  
  it_should_behave_like "a supplier"  do
    let(:create_supplier_card) { Card.gimme! "test css", :type => :css, :content => css }
    let(:create_factory_card)  { Card.gimme! "style with css+*style", :type => :pointer }
    let(:card_content) do
       { in:       css,         out:     compressed_css, 
         new_in:   changed_css, new_out: compressed_changed_css }
    end
  end

  it_should_behave_like 'a content card factory', that_produces_css do
    let(:factory_card) {  Card.gimme! "test css", :type => :css, :content => css }
    let(:card_content) do
       { in:       css,         out:     compressed_css, 
         new_in:   changed_css, new_out: compressed_changed_css }
    end
  end
end
