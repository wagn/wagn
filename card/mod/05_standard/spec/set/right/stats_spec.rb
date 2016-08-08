# -*- encoding : utf-8 -*-

describe Card::Set::Right::Stats do
  context "core view" do
    it "should have a table" do
      Card::Auth.as_bot do
        @core = render_card :core, name: "A+*stats"
        assert_view_select @core, "table"
      end
    end
  end
end
