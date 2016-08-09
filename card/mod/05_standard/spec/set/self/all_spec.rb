# -*- encoding : utf-8 -*-

describe Card::Set::Self::All do
  before do
    @all = Card[:all]
  end

  context "#update" do
    it "should trigger empty trash (with right params)" do
      Card::Auth.as_bot do
        Card["A"].delete!
        expect(Card.where(trash: true)).not_to be_empty
        Card::Env.params[:task] = :empty_trash
        @all.update_attributes({})
        expect(Card.where(trash: true)).to be_empty
      end
    end

    it "should trigger deleting old revisions (with right params)" do
      Card::Auth.as_bot do
        a = Card["A"]
        a.update_attributes! content: "a new day"
        a.update_attributes! content: "another day"
        expect(a.actions.count).to eq(3)
        Card::Env.params[:task] = :delete_old_revisions
        @all.update_attributes({})
        expect(a.actions.count).to eq(1)
      end
    end

    #     it 'should be trigger reference repair' do
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
