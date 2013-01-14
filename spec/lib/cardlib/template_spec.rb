require File.expand_path('../../spec_helper', File.dirname(__FILE__))


describe Card do

  describe "#hard_templatees" do
    it "for User+*type+*content should return all Users" do
      Account.as_bot do
        c=Card.create(:name=>'User+*type+*content')
        c.hard_templatee_names.sort.should == [
          "Joe Admin", "Joe Camel", "Joe User", "John", "No Count", "Sample User", "Sara", "u1", "u2", "u3"
        ]
      end
    end
  end

  it "#expire_templatee_references" do
    #TESTME
  end

end





describe Card, "with right content template" do
  before do
    Account.as_bot do
      @bt = Card.create! :name=>"birthday+*right+*content", :type=>'Date', :content=>"Today!"
    end
    Account.as :joe_user
    @jb = Card.create! :name=>"Jim+birthday"
  end

  it "should have default content" do
    Wagn::Renderer.new(@jb)._render_raw.should == 'Today!'
  end

  it "should change content with template" do
    Account.as_bot do
      @bt.content = "Tomorrow"; @bt.save!
    end
    Wagn::Renderer.new( Card['Jim+birthday']).render(:raw).should == 'Tomorrow'
  end
end


describe Card, "with right default template" do
  before do
    Account.as_bot  do
      @bt = Card.create! :name=>"birthday+*right+*default", :type=>'Date', :content=>"Today!"
    end
    Account.as :joe_user
    @jb = Card.create! :name=>"Jim+birthday"
  end

  it "should have default cardtype" do
    @jb.typecode.should == :date
  end

  it "should have default content" do
    Card['Jim+birthday'].content.should == 'Today!'
  end
end

describe Card, "templating" do
  before do
    Account.as_bot do
      Card.create :name=>"Jim+birthday", :content=>'Yesterday'
      @dt = Card.create! :name=>"Date+*type+*content", :type=>'Basic', :content=>'Tomorrow'
      @bt = Card.create! :name=>"birthday+*right+*content", :type=>'Date', :content=>"Today"
    end
  end

  it "*right setting should override *type setting" do
    Card['Jim+birthday'].raw_content.should == 'Today'
  end

  it "should defer to normal content when *content rule's content is (exactly) '_self'" do
    Account.as_bot { Card.create! :name=>'Jim+birthday+*self+*content', :content=>'_self' }
    Card['Jim+birthday'].raw_content.should == 'Yesterday'
  end
end

describe Card, "with type content template" do
  before do
    Account.as_bot do
      @dt = Card.create! :name=>"Date+*type+*content", :type=>'Basic', :content=>'Tomorrow'
    end
  end

  it "should return templated content even if content is passed in" do
    Wagn::Renderer.new(Card.new(:type=>'Date', :content=>''))._render(:raw).should == 'Tomorrow'
  end
end



