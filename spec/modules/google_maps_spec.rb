require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
  

describe GoogleMapsAddon do
  before(:each) do 
    User.as :joe_user
    @geotest = Card.new(:name=>"Geotest")     
  end

  it "should do nothing given no configuration" do
    @geotest.save
    Card["Geotest+*geocode"].should be_nil
  end             
  
  context "given a *geocode configuration" do   
    before(:each) do
      User.as :wagbot do
        Card.create! :name=>"*geocode", :content => "[[street address]]\n[[zip]]", :type=>'Pointer'
      end 
    end
    
    it "should save geocoding to +*geocode when configured cards card are present" do              
      GoogleMapsAddon.should_receive(:geocode).with("519 Peterson St 80524").and_return('40.581144, -105.071947')
      Card.create! :name=>"Ethan's House+street address", :content => "519 Peterson St 80524"
      Card["Ethan's House+*geocode"].should_not be_nil 
      Card["Ethan's House+*geocode"].typecode.should == 'Phrase'
      Card["Ethan's House+*geocode"].content.should == '40.581144, -105.071947'
    end
  end
end
  
                   
