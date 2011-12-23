require File.expand_path('../../spec_helper', File.dirname(__FILE__))

# FIXME this shouldn't be here
describe Wagn::Set::Type::Cardtype, ".create with :codename" do
  before do
    User.as :joe_user
  end
  it "should work" do
    Card.create!(:name=>"Foo Type", :codename=>"foo", :type=>'Cardtype').typecode.should=='Cardtype'
  end
end



describe Card, ".create_these" do
  it 'should create basic cards given name and content' do 
    Card.create_these "testing_name" => "testing_content" 
    Card["testing_name"].content.should == "testing_content"
  end

  it 'should return the cards it creates' do 
    c = Card.create_these "testing_name" => "testing_content" 
    c.first.content.should == "testing_content"
  end

  it 'should create cards of a given type' do
    Card.create_these "Cardtype:Footype" => "" 
    Card["Footype"].typecode.should == "Cardtype"
  end   
  
  it 'should take a hash of type:name=>content pairs' do
    Card.create_these 'AA'=>'aa', 'BB'=>'bb'      
    Card['AA'].content.should == 'aa'
    Card['BB'].content.should == 'bb'
  end
  
  it 'should take an array of {type:name=>content},{type:name=>content} hashes' do
    Card.create_these( {'AA'=>'aa'}, {'AA+BB'=>'ab'} )
    Card['AA'].content.should == 'aa'
    Card['AA+BB'].content.should == 'ab'
  end
end



describe Card, "created by Card.new " do
  before(:each) do     
    User.as :wagbot 
    @c = Card.new :name=>"New Card", :content=>"Great Content"
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
    Card.create! :name => "blue+*right+*default", :content => "joe", :type=>"Pointer"
    c = Card.new :name => "Lady+blue", :content => "[[Jimmy]]"
    c.content.should == "[[Jimmy]]"
  end
end
                  


describe Card, "created by Card.create with valid attributes" do
  before(:each) do
    User.as :wagbot 
    @b = Card.create :name=>"New Card", :content=>"Great Content"
    @c = Card.find(@b.id)
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
    Card.find_by_name("New Card").class.should == Card
  end  
end

describe Card, "create junction" do
  before(:each) do
    User.as :joe_user
    @c = Card.create! :name=>"Peach+Pear", :content=>"juicy"
  end

  it "should not have errors" do
    @c.errors.size.should == 0
  end

  it "should create junction card" do
    Card.find_by_name("Peach+Pear").class.should == Card
  end

  it "should create trunk card" do
    Card.find_by_name("Peach").class.should == Card
  end

  it "should create tag card" do
    Card.find_by_name("Pear").class.should == Card
  end
end



describe Card, "types" do
  before do
    User.as :wagbot  
    # NOTE: it looks like these tests aren't DRY- but you can't pull the cardtype creation up here because:
    #  creating cardtypes creates constants in the namespace, and those aren't removed 
    #  when the db is rolled back, so you're not starting in the original state.
    #  during use of the application the behavior probably won't create a problem, so we test around it here.
  end
  
  it "should accept cardtype name and casespace variant as type" do
    ct = Card.create! :name=>"AFoo", :type=>'Cardtype'
    ct.typecode.should == 'Cardtype'
    ct = Card.fetch('AFoo')
    ct.extension.class_name.should == 'AFoo'
    ct.update_attributes! :name=>"FooRenamed", :confirm_rename=>true
    Card.fetch('FooRenamed').typecode.should == 'Cardtype'
    Card.fetch('FooRenamed').extension.class_name.should == 'AFoo'
   
    Cardtype.cache.reset
    Card.reset_types
    Card.create!(:type=>"FooRenamed",:name=>"testy").typecode.should == 'AFoo'
    Card.create!(:type=>"foo_renamed",:name=>"so testy").typecode.should == 'AFoo'
  end
  it "should accept classname as typecode" do
    ct = Card.create! :name=>"BFoo", :type=>'Cardtype'
    ct.update_attributes! :name=>"BFooRenamed"
    ct.extension.class_name.should == 'BFoo'
    Card.create!(:typecode=>"BFoo",:name=>"testy").typecode.should == 'BFoo'
  end
  
  it "should accept cardtype name first when both are present" do
    ct = Card.create! :name=>"CFoo", :type=>'Cardtype'
    ct.update_attributes! :name=>"CFooRenamed"
    Card.create! :name=>"CFoo", :type=>'Cardtype'
    Card.create!(:type=>"CFoo",:name=>"testy").typecode.should == 'CFoo1'
  end
  
  it "should raise a validation error if a bogus type is given" do
    ct = Card.create! :name=>"DFoo", :type=>'Cardtype'
    c = Card.new(:type=>"$d_foo#adfa",:name=>"more testy")
    c.valid?.should be_false
    c.errors_on(:type).should_not be_empty
  end
end          

