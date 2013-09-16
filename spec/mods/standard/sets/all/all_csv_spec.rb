# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card::Set::All::AllCsv, "CSV mod" do
  context "csvrow view" do
    it "should handle inclusions" do
      render_card( :csvrow, { :content=>'{{A+B}} {{T}}' }, :format => :csv ).should == "AlphaBeta,Theta"
    end
  end
end
