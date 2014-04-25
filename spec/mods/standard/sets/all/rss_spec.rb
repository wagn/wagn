# -*- encoding : utf-8 -*-

describe Card::Set::All::Rss do
  it 'should render recent.rss' do
    rendered = Card[:recent].format(:format=>:rss).show( nil, {} )
    rendered.should =~ /xml/
  end
end
