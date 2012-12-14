require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe Card, "admin functions" do
  before(:each) do
    Account.as :joe_user
  end

  describe "setup first user"
  before do
    Account.as_bot do
      Card.search(:type => :user).each do |card|
        card.destroy
      end
    end

    it "should setup" do
      post '/:setup', :account => {:email=>'admin@joe'}
    end
  end

  it "should clear cache" do
  end

  it "should show cache" do
    get '/A/view=show_cache'
  end
end
