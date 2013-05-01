# -*- encoding : utf-8 -*-
require File.expand_path('../../../../spec_helper', File.dirname(__FILE__))
require File.expand_path('../../../../packs/pack_spec_helper', File.dirname(__FILE__))

describe Wagn::Set::All::AllCsv, "CSV pack" do
  context "csvrow view" do
    it "should handle inclusions" do
      render_card( :csvrow, { :content=>'{{A+B}} {{T}}' }, :format => :csv ).should == "AlphaBeta,Theta"
    end
  end
end
