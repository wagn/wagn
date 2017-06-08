# -*- encoding : utf-8 -*-

describe Card::Set::Type::Toggle do
  it "has special editor" do
    assert_view_select render_editor("Toggle"), 'input[type="checkbox"]'
  end

  it "has yes/no as processed content" do
    expect(render_view(:core, type: "Toggle", content: "0")).to eq("no")
    expect(render_view(:closed_content, type: "Toggle", content: "1"))
      .to eq("yes")
  end

  describe "view :labeled_editor" do
    subject { render_view :labeled_editor, type: :toggle, name: "A+toggle" }
    it "has checkbox label" do
      is_expected.to have_tag("label", with: { for: "card_content" }) do
        with_text "toggle"
      end
    end
  end
end


