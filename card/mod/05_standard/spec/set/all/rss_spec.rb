# -*- encoding : utf-8 -*-

describe Card::Set::All::Rss do
  it 'should render recent.rss' do
    rendered = Card[:recent].format(:rss).show( nil, {} )
    expect(rendered).to match(/xml/)
  end
end
