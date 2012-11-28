require File.expand_path('../spec_helper', File.dirname(__FILE__))


describe GoogleMapsAddon do
  before(:each) do
    Account.as :joe_user
    @geotest = Card.new(:name=>"Geotest")
  end

  it "should do nothing given no configuration" do
    @geotest.save
    Card["Geotest+*geocode"].should be_nil
  end

  context "given a *geocode configuration" do
    before(:each) do
      Account.as_bot do
        Card.create! :name=>"*geocode", :content => "[[street address]]\n[[zip]]", :type=>'Pointer'
      end
    end

    it "should save geocoding to +*geocode when configured cards card are present" do
      mock(GoogleMapsAddon).geocode("519 Peterson St 80524").returns('40.581144, -105.071947')
      Account.as_bot do
        # FIXME: rules for this should be standard?
        Card.create :name=>"*geocode+*right+*update", :content=>'[[Anyone Signed In]]'
        Card.create :name=>"*geocode+*right+*create", :content=>'[[Anyone Signed In]]'
      end
      Card.create! :name=>"Ethan's House+street address", :content => "519 Peterson St 80524"
      Card["Ethan's House+*geocode"].should_not be_nil
      Card["Ethan's House+*geocode"].typecode.should == :phrase
      Card["Ethan's House+*geocode"].content.should == '40.581144, -105.071947'
    end
  end
end


