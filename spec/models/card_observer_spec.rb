require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CardObserver do     
  before(:each) do
    Wagn::Hook.reset  # this is really just here to trigger hook auto-loading
  end
  
  it "invokes cardhooks on create" do
    card = Card.new :name => "testit"  
    [:before_save, :before_create, :after_save, :after_create].each do |hookname|
      Wagn::Hook.should_receive(:invoke).with(hookname, card)
    end 
    User.as :wagbot do
      card.save
    end
  end
end