# -*- encoding : utf-8 -*-

describe Card::Set::Type::Scss do
  before do
    @scss_card = Card[:style_functional]
  end
  
  it 'should highlight code in html' do
    assert_view_select @scss_card.format.render_core, 'div[class=CodeRay]'
  end
  
  it 'should not highlight code in css' do
    @scss_card.format(:format=>:css).render_core.should_not =~ /CodeRay/
  end
  
end
