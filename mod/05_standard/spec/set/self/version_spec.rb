# -*- encoding : utf-8 -*-

describe Card::Set::Self::Version do
  it "should have an X.X.X version" do
    (render_card(:raw, :name=>'*version') =~ (/\d\.\d+\.\w+/ )).should be_true
  end
end
