require File.dirname(__FILE__) + '/../../spec_helper'

describe Card, "attribute tracking for new card" do
  before(:each) do     
    User.as :admin
    @c = Card::Basic.new :name=>"New Card", :content=>"Great Content"
  end
  
  it "should have updates" do
    ActiveRecord::AttributeTracking::Updates.should === @c.updates
  end
  
  it "should return original value" do
    @c.name.should == 'New Card'
  end
  
  it "should track changes" do
    @c.name = 'Old Card'
    @c.name.should == 'Old Card'
  end
end

describe Card, "basic create" do
  before(:each) do
    User.as :admin
    @b = Card.create :name=>"New Card", :content=>"Great Content"
    @c = Card.find(@b.id)
  end

  it "should not have errors"        do @b.errors.size.should == 0        end
  it "should have the right class"   do @c.class.should    == Card::Basic end
  it "should have the right key"     do @c.key.should      == "new_card"  end
  it "should have the right name"    do @c.name.should     == "New Card"  end
  it "should have the right content" do @c.content.should  == "Great Content" end

  it "should have a revision with the right content" do
    @c.current_revision.content == "Great Content"
  end

  it "should be findable by name" do
    Card.find_by_name("New Card").class.should == Card::Basic
  end  
end

describe Card, "create junction" do
  before(:each) do
    User.as :admin
    @c = Card.create :name=>"Peach+Pear", :content=>"juicy"
  end

  it "should not have errors" do
    @c.errors.size.should == 0
  end

  it "should create junction card" do
    Card.find_by_name("Peach+Pear").class.should == Card::Basic
  end

  it "should create trunk card" do
    Card.find_by_name("Peach").class.should == Card::Basic
  end

  it "should create tag card" do
    Card.find_by_name("Pear").class.should == Card::Basic
  end
end
                       