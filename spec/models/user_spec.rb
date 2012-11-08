require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe "User" do
  describe "#read_rules" do
    before(:all) do
      @read_rules = Card['joe_user'].read_rules
    end


    it "*all+*read should apply to Joe User" do
      @read_rules.member?(Card.fetch('*all+*read').id).should be_true
    end

    it "3 more should apply to Joe Admin" do
      Session.as(:joe_admin) do
        ids = Session.as_card.read_rules
        #warn "rules = #{ids.map(&Card.method(:find)).map(&:name) * ', '}"
        ids.length.should == @read_rules.size+3
      end
    end

  end
end
