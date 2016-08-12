# -*- encoding : utf-8 -*-

describe Card::Set::Rstar::Rules do
  it "should render setting view for a right set" do
    r = Card["*read+*right"].format.render_open
     expect(r).not_to match(/error/i)
     expect(r).not_to match("No Card!")
     # warn "r = #{r}"
     assert_view_select r, 'table[class="set-rules table"]' do
       assert_select 'a[href~="/*read+*right+*read?view=open_rule"]', text: "read"
     end
  end

  it "should render setting view for a *input rule" do
    Card::Auth.as_bot do
      r = Card.fetch("*read+*right+*input", new: {}).format.render_open_rule
      expect(r).not_to match(/error/i)
      expect(r).not_to match("No Card!")
      # warn "r = #{r}"
      assert_view_select r, 'tr[class="card-slot open-rule edit-rule"]' do
        assert_select 'input[id="success_id"][name=?][type="hidden"][value="*read+*right+*input"]', "success[id]"
      end
    end
  end
end
