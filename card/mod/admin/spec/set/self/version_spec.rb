# -*- encoding : utf-8 -*-

describe Card::Set::Self::Version do
  it "should have an X.X.X version" do
    expect(render_card(:raw, name: "*version") =~ /\d\.\d+\.\w+/).to be_truthy
  end
end
