# -*- encoding : utf-8 -*-

describe Card::Action do
  describe "#delete_old_actions" do
    it "puts all changes on one action" do
      a = Card["A"]
      a.update_attributes!(name: "New A")
      a.update_attributes!(content: "New content")
      a.delete_old_actions
      expect(a.actions.count).to eq(1)
      expect(a.actions(true).last.value :name).to eq("New A")
    end
  end
end
