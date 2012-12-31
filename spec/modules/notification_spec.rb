require File.expand_path('../spec_helper', File.dirname(__FILE__))
require File.expand_path('../../test/seed', File.dirname(__FILE__))
FUTURE = SharedData::FUTURE


describe "Card" do
  before do
    Timecop.travel(FUTURE)  # make sure we're ahead of all the test data
    @just_s = [Card["Sara"].id]
    @s_and_j= [Card["Sara"].id, Card["John"].id]
  end

  describe "#watchers" do
    it "returns users watching this card specifically" do
      Card["All Eyes On Me"].watchers.should == @s_and_j
    end

    it "returns users watching cards of this type" do
      Card["Sunglasses"].watchers.should == @just_s
    end
  end

  describe "#card_watchers" do
    it "returns users watching this card specifically" do
      Card["All Eyes On Me"].watcher_pairs(false).should == @s_and_j
    end
  end

  describe "#type_watchers" do
    it "returns users watching cards of this type" do
      Card["Sunglasses"].watcher_pairs(false, :type).should == @just_s
    end
  end
end

describe "On Card Changes" do
  before do
    Account.user= 'john'
    Timecop.travel(FUTURE)  # make sure we're ahead of all the test data
  end

  it "sends notifications of edits" do
    mock(Mailer).change_notice( Card['Sara'].id, Card["Sara Watching"], "edited", "Sara Watching", nil )
    Card["Sara Watching"].update_attributes :content => "A new change"
  end

  it "sends notifications of additions" do
    new_card = Card.new :name => "Microscope", :type => "Optic"
    mock(Mailer).change_notice( Card['Sara'].id, new_card,"added", "Optic", nil  )
    new_card.save!
  end

  it "sends notification of updates" do
    mock(Mailer).change_notice( is_a(Integer), Card["Sunglasses"], "edited", "Optic", nil)
    Card["Sunglasses"].update_attributes :content => 'updated content'
  end

  it "does not send notification to author of change" do
    mock(Mailer).change_notice.with_any_args.times(any_times) do
      |*a| a[0].should_not == Account.user_id
    end

    Card["All Eyes On Me"].update_attributes :content => "edit by John"
  end

  it "does include author in wathers" do
     Card["All Eyes On Me"].watchers.member?(Account.user_id).should be_true
  end
end


describe "Trunk watcher notificatione" do
  before do
    Account.user= 'joe user'
    Timecop.travel(FUTURE)  # make sure we're ahead of all the test data

    Card.create :type=>'Book', :name=>'Ulysses'
    (@ulyss =Card['Ulysses']).should be
    watchers_card = Card.fetch "Ulysses+*watchers", :new=>{}
    c = Card['joe camel']
    watchers_card << c
    @jc_id = c.id
    watchers_card.save
 
    watchers_card = Card.fetch "Book+*watchers", :new=>{}
    c = Card['joe admin']
    watchers_card << c
    @ja_id = c.id
    watchers_card.save
  end

  it "sends notification to Joe Camel" do
    name = "Ulysses+author"
    mock(Mailer).change_notice( @ja_id, @ulyss, "updated", 'Book' , [[name, "added"]], is_a(Card))
    mock(Mailer).change_notice( @jc_id, @ulyss, "updated", @ulyss.name , [[name, "added"]], is_a(Card))
    c=Card.create :name=>name, :content => "James Joyce"
  end

end
