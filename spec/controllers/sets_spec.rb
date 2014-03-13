require 'wagn/spec_helper'
=begin
describe CardController, "Basic rendering tests" do

  before do
    @sample_cards = Card.where("cards.key like 'sample_%' and cards.key not like '%+%'")
  end

  # these tests are increasingly lame.
  # how about we actually test for presence of a few things ?

  describe "for anonymous" do
    before do
      login_as :anonymous
    end

    it "should get changes for basic" do
      card = Card['Sample Basic']
      card.new_card?.should be_false
      get :read, :id => "~#{card.id}", :view=>'changes'
      assert_response :success
    end

    it "should read all types" do
      @sample_cards.each do |sample|
        get :read, :id => "~#{sample.id}"
        assert_response :success
      end
    end

    it "should get options for all types" do
      @sample_cards.each do |sample|
        get :read, :id => "~#{sample.id}", :view=>'options'
        assert_response :success
      end
    end

    it "should get edit form for all types" do
      @sample_cards.each do |sample|
        get :read, :id => "~#{sample.id}", :view=>'edit'
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
      get :read, :id => "~#{Card['Sample Basic'].id}", :view=>'changes'
      assert_response :success
    end

    it "should read all types" do
      @sample_cards.each do |sample|
        get :read, :id => "~#{sample.id}"
        assert_response :success
      end
    end

    it "should get options for all types" do
      @sample_cards.each do |sample|
        get :read, :id => "~#{sample.id}", :view=>'options'
        assert_response :success
      end
    end

    it "should get edit form for all types" do
      @sample_cards.each do |sample|
        if %w{ sample_html sample_layout sample_css sample_scss sample_skin }.member? sample.key
          login_as 'Joe Admin' do
            get :read, :id => "~#{sample.id}", :view=>'edit'
          end
        else
          get :read, :id => "~#{sample.id}", :view=>'edit'
        end
        response.should be_success, "Getting #{sample.inspect}"
      end
    end

    it "should get new for basic" do
      get :read, :id=>'', :view=>'new'
      assert_response :success
    end

  end

end
=end

