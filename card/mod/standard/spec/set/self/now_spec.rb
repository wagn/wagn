# -*- encoding : utf-8 -*-

describe Card::Set::Self::Now do
  it "should have a date" do
    expect(render_card(:raw, name: "*now").match(/\w+day, \w+ \d+, \d{4}/)).not_to be_nil
  end
end
