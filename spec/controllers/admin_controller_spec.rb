require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe AdminController, "admin functions" do
  before do
    Account.as_bot do
      Card.search(:type => Card::UserID).each do |card|
        card.destroy
      end
    end
  end

  it "should setup be ready to setup" do
    post :setup, :account => {:email=>'admin@joe'}
  end

  it "should clear cache" do
    Account.as :joe_user do
      get :clear_cache
    end
  end

  it "should show cache" do
    Account.as :joe_user do
      get :show_cache, :id=>"A"
    end
  end
end
