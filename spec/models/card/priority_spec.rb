require File.dirname(__FILE__) + '/../../spec_helper'

describe Card, "simple priority on create" do
  before do    
    User.as :admin
    @bp = Card.create! :name=>"Banana+*priority", :content=>"5"
  end
  
  it "should set priority on trunk" do
    @bp.trunk.priority.should == 5
  end
end

describe Card, "simple priority on update" do
  before do
    User.as :admin
    @bp = Card.create! :name=>"Banana+*priority", :content=>"5"
    @bp.update_attributes! :content=>"20"
  end
  
  it "should set priority on trunk" do
    @bp.trunk.priority.should == 20
  end
end

describe Card, "junction priority on update" do
  before do
    User.as :admin
    @ac = Card.create! :name=>"Apple+color"
    @color = Card.create! :name=>"color+*priority", :content=>"7"
  end
  
  it "should set priority on junction" do
    @ac.reload.priority.should == 7
  end
end

describe Card, "junction priority on create" do
  before do
    User.as :admin
    @color = Card.create! :name=>"color+*priority", :content=>"7"
    @ac = Card.create! :name=>"Apple+color"
  end
  
  it "should set priority on junction" do
    @ac.reload.priority.should == 7
  end
end
