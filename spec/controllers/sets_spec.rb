
require File.expand_path('../spec_helper', File.dirname(__FILE__))
include AuthenticatedTestHelper

describe CardController do
  it "module exists and autoloads" do
    Wagn::Sets.should be_true
  end

  describe "read all set" do
    it "gets data" do
      get :read, :id=>'a'
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


describe CardController, "Basic rendering tests" do

  before do
    @sample_cards = Card.where("cards.key like 'sample_%'")
  end

  #these tests are increasingly lame.
  # how about we actually test for presense of a few things ?

  describe "for anonymous" do
    before do
      login_as :anonymous
    end

    it "should get changes for basic" do
      card = Card['Sample Basic']
      card.should be
      get :read, :id => card.id, :view=>'changes'
      assert_response :success
    end

    it "should read all types" do
      @sample_cards.each do |sample|
        get :read, :id => sample.id
        assert_response :success
      end
    end

    it "should get options for all types" do
      @sample_cards.each do |sample|
        get :read, :id => sample.id, :view=>'options'
        assert_response :success
      end
    end

    it "should get edit form for all types" do
      @sample_cards.each do |sample|
        get :read, :id => sample.id, :view=>'edit'
        assert_response :forbidden
      end
    end

    it "should get new for basic" do
      get :read, :view=>'new'
      assert_response :forbidden
    end
  end

  describe "for joe user" do
    before do
      login_as 'Joe User'
    end

    it "should get changes for basic" do
      get :read, :id => Card['Sample Basic'].id, :view=>'changes'
      assert_response :success
    end

    it "should read all types" do
      @sample_cards.each do |sample|
        get :read, :id => sample.id
        assert_response :success
      end
    end

    it "should get options for all types" do
      @sample_cards.each do |sample|
        get :read, :id => sample.id, :view=>'options'
        assert_response :success
      end
    end

    it "should get edit form for all types" do
      @sample_cards.each do |sample|
        get :read, :id => sample.id, :view=>'edit'
        response.should be_success, "Getting #{sample.inspect}"
      end
    end

    it "should get new for basic" do
      get :read, :id=>'', :view=>'new'
      assert_response :success
    end

  end

end


