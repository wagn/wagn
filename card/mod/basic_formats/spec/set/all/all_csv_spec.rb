# -*- encoding : utf-8 -*-

describe Card::Set::All::AllCsv, "CSV mod" do
  context "csv_row view" do
    it "handles nests" do
      rendered = render_card :csv_row, { content: "{{A+B}} {{T}}" },
                             format: :csv
      expect(rendered).to eq("AlphaBeta,Theta")
    end
  end
end
