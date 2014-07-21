# -*- encoding : utf-8 -*-

describe Card::Set::All::AllCsv, "CSV mod" do
  context "csv_row view" do
    it "should handle inclusions" do
      render_card( :csv_row, { :content=>'{{A+B}} {{T}}' }, :format => :csv ).should == "AlphaBeta,Theta"
    end
  end
end
