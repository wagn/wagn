require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe "Ruby Cardtype" do
  before do
    Card.as(Card::WagbotID)
    #raise "ruby cards getting into infinite loop on save??"
    #c = Card.create :type => "Cardtype", :name => "Ruby"
    #c.codename = "Ruby"
    #c.save!
    #
    #Card.create! :name => "a1", :type => "Number", :content => "3"
    #Card.create! :name => "b1", :type => "Number", :content => "4"
    #Card.create! :name => "d1", :type => "Number", :content => "5"
    #Card.create! :name => "a1+b1"
    #Card.create! :name => "b1+d1"
    #Card.create! :name => "lr sum+*right+*content", :type => "Ruby", :content => "{{_1|core}}+{{_2|core}}"
    #Card.create! :name => "a1test", :type=>"Phrase", :content => "{{a1+b1+lr sum|core}}, {{b1+d1+lr sum|core}}"
    #
    #Wagn.stub(:enable_ruby_cards).and_return(true)
  end

  it "should keep different ruby cards straight" do
    pending
    card = Card.create! :name => "final", :content => "{{a1test|core}}" 
    Wagn::Renderer.new(card).render(:core).should == "7, 9"
  end
  
end
