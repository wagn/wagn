
require File.expand_path('../spec_helper', File.dirname(__FILE__))
#include AuthenticatedTestHelper

describe CardController do
  it "module exists and autoloads" do
    Wagn::Sets.should be_true
  end

  describe "read all set" do
    it "gets data" do
      get :read, :id=>'a'
      #controller.process_read.should be
    end
  end

  describe ".process_read" do
    before do
    end

    it "invokes actions on matching cards" do
    end

    it "does not invoke actions on non-matching cards" do
    end

    it "invokes actions for set names" do

    end

    it "invokes multiple registered actions with arguments" do
    end
  end
end


