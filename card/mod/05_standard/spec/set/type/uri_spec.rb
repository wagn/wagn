# -*- encoding : utf-8 -*-

describe Card::Set::Type::Uri do
  it "should have special editor" do
    assert_view_select render_editor("Uri"), 'input[type="text"][class~="card-content"]'
  end

  it "renders core view links" do
    card = Card.create(type: "URI", name: "A URI card", content: "http://wagn.org/Home")
    assert_view_select card.format.render("core"), 'a[class="external-link"][href="http://wagn.org/Home"]' do
      assert_select 'span[class="card-title"]', text: "A URI card"
    end
  end

  it "renders core view links with title arg" do
    card = Card.create(type: "URI", name: "A URI card", content: "http://wagn.org/Home")
    assert_view_select card.format.render("core", title: "My Title"), 'a[class="external-link"][href="http://wagn.org/Home"]' do
      assert_select 'span[class="card-title"]', text: "My Title"
    end
  end

  it "renders title view in a plain formatter" do
    card = Card["A"]
    card.format(:text).render("title", title: "My Title").should == "My Title"
    card.format(:text).render("title").should == "A"
  end

  it "renders url_link for regular cards" do
    card = Card["A"]
    card.format(:text).render("url_link").should == "/A"
    assert_view_select card.format.render("url_link"),
                       'a[class="internal-link"][href="/A"]',
                       text: "/A"
  end

  it "renders a url_link view" do
    card = Card.create(type: "URI", name: "A URI card", content: "http://wagn.org/Home")
    assert_view_select card.format.render("url_link"), 'a[class="external-link"]', text: "http://wagn.org/Home"
    card.format(:text).render("url_link").should == "http://wagn.org/Home"
  end
end
