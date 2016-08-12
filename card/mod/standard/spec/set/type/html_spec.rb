# -*- encoding : utf-8 -*-

describe Card::Set::Type::Html do
  before do
    Card::Auth.current_id = Card::WagnBotID
  end

  it "has special editor" do
    assert_view_select render_editor("Html"), 'textarea[rows="5"]'
  end

  it "does not render any content in closed view" do
    rendered = render_card :closed_content,
                           type: "Html",
                           content: "<strong>Lions and Tigers</strong>"
    expect(rendered).to eq("")
  end

  it "renders nests" do
    rendered = render_card :core, type: "HTML", content: "{{a}}"
    expect(rendered).to match(/slot/)
  end

  it "does not render uris" do
    rendered = render_card :core, type: "HTML", content: "http://google.com"
    expect(rendered).not_to match(/\<a/)
  end
end
