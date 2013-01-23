require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe Wagn::Codename, "Codename" do

  before do
    @codes = Wagn::Codename.codehash.each_key.find_all do |key|
      Symbol===key
    end
  end

  it "should have sane codename data" do
    @codes.each do |code|
      code.                      should be_instance_of Symbol
      (i = Wagn::Codename[code]).should be_a_kind_of Integer
      Wagn::Codename[i].         should == code
    end
  end

  it "cards should exist and be indestructable" do
    Account.as_bot do
      @codes.each do |code|
        card = Card[code]
        card.delete
        if err = card.errors[:cardtype].first
          err.should match "can't be altered because"
        elsif err = card.errors[:delete].first
          err.should match 'is a system card'
        end
        Card[code].should be
      end
    end
  end
end
