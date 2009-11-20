module PatternExampleGroupMethods
  def it_accepts( pattern_spec )
    it "accepts #{pattern_spec.inspect}" do
      described_class.recognize( pattern_spec ).should be_true
    end
  end
  
  def it_rejects( pattern_spec )
    it "rejects #{pattern_spec.inspect}" do
      described_class.recognize( pattern_spec ).should be_false
    end
  end
  
  def it_generates( opts )
    key = opts[:key]
    if opts[:from].is_a?(Card::Base)
      card = opts[:from]
      it "generates key '#{key}' for card '#{card.name}'" do
        described_class.key_for_card( card ).should == key
      end
    else
      spec = opts[:from]
      it "generates key '#{key}' for spec '#{spec.inspect}'" do
        described_class.key_for_spec( spec ).should == key
      end
    end
  end
end

ActiveSupport::TestCase.extend PatternExampleGroupMethods
