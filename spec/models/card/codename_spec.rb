require File.expand_path('../../spec_helper', File.dirname(__FILE__))

#FIXME: all this belongs someplace else (or delete it)

describe Card::Codename, "Codename" do
  it "should have sane codename data" do
    Card::Codename.codes.each do |code|
      code.                      should be_instance_of Symbol
      (i = Card::Codename[code]).should be_a_kind_of Integer
      Card::Codename[i].         should == code
    end
  end

  it "cards should exist and be indestructable" do
    Card::Codename.codes.each do |code|
      (card=Card[code]).confirm_destroy = true
      card.destroy
      if err = card.errors[:cardtype].first
        err.should match "can't be altered because"
      elsif err = card.errors[:destroy].first
        err.should match 'is a system card'
      end
      Card[code].should be
    end
  end
end
