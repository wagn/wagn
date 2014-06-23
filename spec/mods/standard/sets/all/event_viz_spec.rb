# -*- encoding : utf-8 -*-

describe Card::Set::All::EventViz do
  describe '#events' do
    Card['A'].events( :update ).split("\n").length.should > 20
  end
end
