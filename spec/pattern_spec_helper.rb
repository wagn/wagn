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
end

ActiveSupport::TestCase.extend PatternExampleGroupMethods
