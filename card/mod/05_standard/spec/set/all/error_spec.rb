# -*- encoding : utf-8 -*-

describe Card::Set::All::Error do
  describe "missing view" do
    it "should prompt to add" do
      expect(render_content("{{+cardipoo|open}}").match(/Add \<span/)).not_to be_nil
    end
  end
end
