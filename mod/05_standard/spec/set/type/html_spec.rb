# -*- encoding : utf-8 -*-

describe Card::Set::Type::Html do
  before do
    Card::Auth.current_id = Card::WagnBotID
  end

  it "should have special editor" do
    assert_view_select render_editor('Html'), 'textarea[rows="5"]'
  end

  it "should not render any content in closed view" do
    expect(render_card(:closed_content, :type=>'Html', :content=>"<strong>Lions and Tigers</strong>")).to eq('')
  end

  it "should render inclusions" do
    expect(render_card( :core, :type=>'HTML', :content=>'{{a}}' )).to match(/slot/)
  end

  it 'should not render uris' do
    expect(render_card( :core, :type=>'HTML', :content=>'http://google.com' )).not_to match(/\<a/)
  end
end
