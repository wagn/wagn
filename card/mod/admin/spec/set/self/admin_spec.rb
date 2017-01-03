# -*- encoding : utf-8 -*-

describe Card::Set::Self::Admin do
  it "renders a table" do
    Card::Auth.as_bot do
      @core = render_card :core, name: :admin
    end
    assert_view_select @core, "table"
  end

  context "#update" do
    before do
      @admin = Card[:admin]
    end

    it "triggers empty trash (with right params)" do
      Card::Auth.as_bot do
        Card["A"].delete!
        expect(Card.where(trash: true)).not_to be_empty
        Card::Env.params[:task] = :empty_trash
        @admin.update_attributes({})
        expect(Card.where(trash: true)).to be_empty
      end
    end

    # NOTE: I removed this functionality for now, because I don't think we
    # should have web access to admin functions that can incur actual data loss.

    # it "triggers deleting old revisions (with right params)" do
    #   Card::Auth.as_bot do
    #     a = Card["A"]
    #     a.update_attributes! content: "a new day"
    #     a.update_attributes! content: "another day"
    #     expect(a.actions.count).to eq(3)
    #     Card::Env.params[:task] = :delete_old_revisions
    #     @admin.update_attributes({})
    #     expect(a.actions.count).to eq(1)
    #   end
    # end

    #     it 'is trigger reference repair' do
    #       Card::Auth.as_bot do
    #         a = Card['A']
    #         puts a.references_out.count
    #         Card::Env.params[:task] = :repair_references
    #         puts a.references_out.count
    #         @all.update_attributes({})
    #         puts a.references_out.count
    #
    #       end
    #     end
  end
end
