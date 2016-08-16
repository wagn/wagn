# -*- encoding : utf-8 -*-

describe Card::Set::Right::WhenLastEdited do
  it "should produce a text date" do
    expect(render_card(:core, name: "A+*when last edited")).to match(/\w+ \d+/)
  end
end
