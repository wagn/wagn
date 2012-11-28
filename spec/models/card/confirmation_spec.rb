require File.expand_path('../../spec_helper', File.dirname(__FILE__))


describe Card, "destroy without dependents" do
  before do Account.as(:joe_user); @c = Card["Basic Card"] end

  it "should succeed" do
    @c.destroy.should be_true
  end
end

describe Card, "destroy with dependents" do
  before do Account.as(:joe_user); @c = Card["A"] end

  it "should fail with errors if confirm_destroy not set" do
    @c.destroy.should_not be_true
    @c.errors[:confirmation_required].should_not be_nil
  end

  it "should succeed if confirm_destroy is set" do
    @c.confirm_destroy = true
    @c.destroy.should be_true
  end
end

describe Card, "rename without dependents" do
  before do Account.as(:joe_user); @c = Card["Basic Card"] end

  it "should succeed" do
    @c.name = "Brand New Name"
    @c.save.should be_true
  end
end

describe Card, "rename with dependants" do
  before do Account.as(:joe_user); @c = Card["A"] end

  it "should fail with errors if confirm_rename is not set" do
    @c.name = "Brand New Name"
    @c.save.should_not be_true
    @c.errors[:confirmation_required].should_not be_nil
  end
end
