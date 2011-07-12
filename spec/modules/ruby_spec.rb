require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Ruby Cardtype" do
  before do
    User.as(:wagbot)
    c = Card.create :type => "Cardtype", :name => "Ruby"
    c.codename = "Ruby"
    c.save!
    
    Card.create! :name => "a1", :type => "Number", :content => "3"
    Card.create! :name => "b1", :type => "Number", :content => "4"
    Card.create! :name => "d1", :type => "Number", :content => "5"
    Card.create! :name => "a1+b1"
    Card.create! :name => "b1+d1"
    Card.create! :name => "lr sum+*right+*content", :type => "Ruby", :content => "{{_1|naked}}+{{_2|naked}}"
    Card.create! :name => "a1test", :type=>"Phrase", :content => "{{a1+b1+lr sum|naked}}, {{b1+d1+lr sum|naked}}"

    System.stub(:enable_ruby_cards).and_return(true)
  end

  it "should keep different ruby cards straight" do
    card = Card.create! :name => "final", :content => "{{a1test|naked}}" 
    Wagn::Renderer.new(card, :context=>"main_1" ).render(:naked ).should == "7, 9"
  end
  
end
