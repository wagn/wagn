module PatternExampleGroupMethods
  def it_generates( opts )
    name = opts[:name]
    card = opts[:from]
    it "generates name '#{name}' for card '#{card.name}'" do
      described_class.set_name( card ).should == name
    end
  end
end

ActiveSupport::TestCase.extend PatternExampleGroupMethods
