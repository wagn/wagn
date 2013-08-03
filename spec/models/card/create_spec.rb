# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

# FIXME this shouldn't be here
describe Card::Set::Type::Cardtype, ".create with :codename" do
  it "should work" do
    Card.create!(:name=>"Foo Type", :codename=>"foo", :type=>'Cardtype').typecode.should==:cardtype
  end
end




describe Card, "created by Card.new " do
  before(:each) do
    Account.as_bot do
      @c = Card.new :name=>"New Card", :content=>"Great Content"
    end
  end

  it "should not override explicit content with default content" do
    Account.as_bot do
      Card.create! :name => "blue+*right+*default", :content => "joe", :type=>"Pointer"
      c = Card.new :name => "Lady+blue", :content => "[[Jimmy]]"
      c.content.should == "[[Jimmy]]"
    end
  end
end



describe Card, "created by Card.create with valid attributes" do
  before(:each) do
    Account.as_bot do
      @b = Card.create :name=>"New Card", :content=>"Great Content"
      @c = Card.find(@b.id)
    end
  end

  it "should not have errors"        do @b.errors.size.should == 0        end
  it "should have the right class"   do @c.class.should    == Card end
  it "should have the right key"     do @c.key.should      == "new_card"  end
  it "should have the right name"    do @c.name.should     == "New Card"  end
  it "should have the right content" do @c.content.should  == "Great Content" end

  it "should have a revision with the right content" do
    @c.current_revision.content == "Great Content"
  end

  it "should be findable by name" do
    Card["New Card"].class.should == Card
  end
end


describe Card, "create junction" do
  before(:each) do
    @c = Card.create! :name=>"Peach+Pear", :content=>"juicy"
  end

  it "should not have errors" do
    @c.errors.size.should == 0
  end

  it "should create junction card" do
    Card["Peach+Pear"].class.should == Card
  end

  it "should create trunk card" do
    Card["Peach"].class.should == Card
  end

  it "should create tag card" do
    Card["Pear"].class.should == Card
  end
end



describe Card, "types" do

end

