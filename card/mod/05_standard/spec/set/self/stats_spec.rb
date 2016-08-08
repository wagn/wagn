# -*- encoding : utf-8 -*-

describe Card::Set::Self::Stats do
  before do
    Card::Auth.as_bot do
      @core = render_card :core, name: :stats
    end
  end
  it "should render a table" do
    assert_view_select @core, "table"
  end
end
