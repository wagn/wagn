# -*- encoding : utf-8 -*-

describe Card::Set::All::Rss do
  it "should render recent.rss" do
    rendered = Card[:recent].format(:rss).show(nil, {})
    expect(rendered).to match(/xml/)
  end

  it "should handle faulty search queries" do
    bad_search = Card.create! name: "Bad Search",
                              type: "Search", content: "not no search"
    rendered = bad_search.format(:rss).render_feed_body
    expect(rendered).to have_tag("item", text: /JSON::ParserError/)
  end

  it "should handle bad queries" do
    bad_search = Card.create! name: "Bad Search",
                              type: "Search", content: '{"found_by":"home"}'
    rendered = bad_search.format(:rss).render_feed_body
    expect(rendered).to have_tag("item", text: /Card::BadQuery/)
  end
end
