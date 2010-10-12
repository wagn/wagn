require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Card do
  context "fetch" do
    it "returns and caches existing cards" do
      Card.fetch("A").should be_instance_of(Card::Basic)
      Card.cache.read("A").should be_instance_of(Card::Basic)
      Card.should_not_receive(:find_by_key)
      Card.fetch("A").should be_instance_of(Card::Basic)
    end

    it "returns nil and caches missing cards" do
      Card.fetch("Zork").should be_nil
      Card.cache.read("Zork").missing.should be_true
      Card.fetch("Zork").should be_nil
    end

    it "returns nil and caches trash cards" do
      User.as(:wagbot)
      Card.fetch("A").destroy!
      Card.fetch("A").should be_nil
      Card.should_not_receive(:find_by_key)
      Card.fetch("A").should be_nil
    end

    it "returns and does not cache builtin cards" do
      Card.fetch("*head").should be_instance_of(Card::Basic)
      Card.cache.read("*head").should be_nil
    end

    it "returns and does not cache virtual cards" do
      # code for this is written.  lazed on test.
      pending
    end

    it "does not recurse infinitively on template templates" do
      Card.fetch("*content+*right+*content").should be_nil
    end

  end

  context "cached cards" do
    it "expires card and dependencies on save" do
      Card.cache.dump  # should be empty
      Card.cache.local.keys.should == []

      User.as :wagbot

      a = Card.fetch("A")
      a.should be_instance_of(Card::Basic)

      # expires the saved card
      Card.cache.should_receive(:delete).with('a')

      # expires plus cards
      Card.cache.should_receive(:delete).with('c+a')
      Card.cache.should_receive(:delete).with('d+a')
      Card.cache.should_receive(:delete).with('f+a')
      Card.cache.should_receive(:delete).with('a+b')
      Card.cache.should_receive(:delete).with('a+c')
      Card.cache.should_receive(:delete).with('a+d')
      Card.cache.should_receive(:delete).with('a+e')
      Card.cache.should_receive(:delete).with('a+b+c')

      # expired including? cards
      Card.cache.should_receive(:delete).with('x').twice
      Card.cache.should_receive(:delete).with('y').twice
      a.save!
    end

    it "expire when dependents are updated" do
      # several more cases of expiration really should be tested.
      # they were not previously tested under and the hook to call Card.cache expirations
      # is essentially the same as the old way.
      pending
    end
  end
end