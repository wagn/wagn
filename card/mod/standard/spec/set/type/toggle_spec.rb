# -*- encoding : utf-8 -*-

describe Card::Set::Type::Toggle do
  it "should have special editor" do
    assert_view_select render_editor("Toggle"), 'input[type="checkbox"]'
  end

  it "should have yes/no as processed content" do
    expect(render_card(:core, type: "Toggle", content: "0")).to eq("no")
    expect(render_card(:closed_content, type: "Toggle", content: "1")).to eq("yes")
  end
end
