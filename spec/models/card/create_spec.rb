require File.expand_path('../../spec_helper', File.dirname(__FILE__))

# FIXME this shouldn't be here
describe Wagn::Set::Type::Cardtype, ".create with :codename" do
  before do
    Account.as :joe_user
  end
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

  it "should have attribute_tracking updates" do
    Wagn::Model::AttributeTracking::Updates.should === @c.updates
  end

  it "should return original value for name" do
    @c.name.should == 'New Card'
  end

  it "should track changes to name" do
    @c.name = 'Old Card'
    @c.name.should == 'Old Card'
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

describe Card, "created with autoname" do
  before do
    Account.as_bot do
      Card.create :name=>'Book+*type+*autoname', :content=>'b1'
    end
  end

  it "should handle cards without names" do
    c = Card.create! :type=>'Book'
    c.name.should== 'b1'
  end

  it "should increment again if name already exists" do
    Card.create :name=>'b1'
    c = Card.create! :type=>'Book'
    c.name.should== 'b2'

  end
end


describe Card, "create junction" do
  before(:each) do
    Account.as :joe_user
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
  before do
    Account.as(Card::WagnBotID)  # FIXME: as without a block is deprecated
    # NOTE: it looks like these tests aren't DRY- but you can't pull the cardtype creation up here because:
    #  creating cardtypes creates constants in the namespace, and those aren't removed
    #  when the db is rolled back, so you're not starting in the original state.
    #  during use of the application the behavior probably won't create a problem, so we test around it here.
  end

  it "should accept cardtype name and casespace variant as type" do
    ct = Card.create! :name=>"AFoo", :type=>'Cardtype', :codename=>'a_foo'
    ct.typecode.should == :cardtype
    ct = Card.fetch('AFoo')
    Wagn::Codename.reset_cache

    ct.update_attributes! :name=>"FooRenamed", :confirm_rename=>true
    (ct=Card.fetch('FooRenamed')).typecode.should == :cardtype
    # now the classname changes if it doesn't have a codename in the table
    ncd = Card.create(:type=>'FooRenamed', :name=>'testy1')
    ncd.type_name.should == 'FooRenamed'
    ncd.typecode.should == :a_foo

    Wagn::Codename.reset_cache
    Card.create!(:type=>"FooRenamed",:name=>"testy").typecode.should == :a_foo
    Card.create!(:type=>"foo_renamed",:name=>"so testy").typecode.should == :a_foo

    Wagn::Codename.reset_cache
  end
  it "should accept classname as typecode" do
    ct = Card.create! :name=>"BFoo", :type=>'Cardtype', :codename=>'b_foo'
    Wagn::Codename.reset_cache

    ct.update_attributes! :name=>"BFooRenamed"

    # give it a codename entry
    # now the classname changes if it doesn't have a codename in the table
    ncd = Card.create(:type=>'BFooRenamed', :name=>'testy2')
    ncd.type_name.should == 'BFooRenamed'
    ncd.typecode.should == :b_foo

    Wagn::Codename.reset_cache
  end

  it "should raise a validation error if a bogus type is given" do
    ct = Card.create! :name=>"DFoo", :type=>'Cardtype'
    c = Card.new(:type=>"$d_foo#adfa",:name=>"more testy")
    c.valid?.should be_false
    c.errors_on(:type).should_not be_empty
  end
end

