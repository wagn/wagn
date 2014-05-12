# -*- encoding : utf-8 -*-

load 'spec/mods/zfactory/lib/factory_spec.rb'
load 'spec/mods/zfactory/lib/supplier_spec.rb'


describe Card::Set::Type::Scss do
  let(:scss) { 
    %{
      $link_color: #0af;
      a { color: $link_color; }  
    }
  }
  let(:compressed_css) {  "a{color:#0af}\n" }
  let(:changed_scss) { 
    %{
      $link_color: #abc; 
      a { color: $link_color; }
    }
  }
  let(:compressed_changed_css) {  "a{color:#abc}\n" }
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
    let(:create_supplier_card) { Card.gimme! "test scss", :type => :scss, :content => scss }
    let(:create_factory_card)  { Card.gimme! "style with scss+*style", :type => :pointer }
    let(:card_content) do
       { in:       scss,         out:     compressed_css, 
         new_in:   changed_scss, new_out: compressed_changed_css }
    end
  end

  it_should_behave_like 'a content card factory', that_produces_css do
    let(:factory_card) {  Card.gimme! "test scss", :type => :scss, :content => scss }
    let(:card_content) do
       { in:       scss,         out:     compressed_css, 
         new_in:   changed_scss, new_out: compressed_changed_css }
    end
  end
end
