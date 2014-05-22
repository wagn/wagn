# -*- encoding : utf-8 -*-

# load 'spec/mods/zfactory/lib/machine_spec.rb'
# load 'spec/mods/zfactory/lib/machine_input_spec.rb'


describe Card::Set::Type::Scss do
  let(:scss) { 
    %{
      $link_color: #0af;
      a { color: $link_color; }  
    }
  }
  let(:compressed_css) {  "a{color:#00aaff}\n" }
  let(:changed_scss) { 
    %{
      $link_color: #abc; 
      a { color: $link_color; }
    }
  }
  let(:compressed_changed_css) {  "a{color:#aabbcc}\n" }
  before do
    @scss_card = Card[:style_functional]
  end
  
  
  it 'should highlight code in html' do
    assert_view_select @scss_card.format.render_core, 'div[class=CodeRay]'
  end
  
  it 'should not highlight code in css' do
    @scss_card.format(:format=>:css).render_core.should_not =~ /CodeRay/
  end
  
  it_should_behave_like "machine input"  do
    let(:create_machine_input_card) { Card.gimme! "test scss", :type => :scss, :content => scss }
    let(:create_machine_card)  { Card.gimme! "style with scss+*style", :type => :pointer }
    let(:card_content) do
       { in:       scss,         out:     compressed_css, 
         new_in:   changed_scss, new_out: compressed_changed_css }
    end
  end

  it_should_behave_like 'content machine', that_produces_css do
    let(:machine_card) {  Card.gimme! "test scss", :type => :scss, :content => scss }
    let(:card_content) do
       { in:       scss,         out:     compressed_css, 
         new_in:   changed_scss, new_out: compressed_changed_css }
    end
  end
end
