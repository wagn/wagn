require File.dirname(__FILE__) + '/../../spec_helper'

describe Card, "New Basic Card" do
  before do
    User.as :wagbot 
    @basic= Card['Basic+*type+*default']
    @r1 = Role.find_by_codename 'r1'
    @basic.permit(:edit, @r1)
    @basic.save!
    User.as :joe_user
    @bc = Card.create! :name=> 'Plain Jane'
  end
  
  it "should have r1 edit permissions because its template is set to that" do
    @bc.who_can(:edit).should==@r1
  end   
  
  it "should not have create permissions assigned directly to the card itself" do
    @bc.who_can(:create).should== nil
  end
end

describe Card, "Basic Card template" do
  context "when a create permission is submitted" do 
    before do
      User.as :wagbot 
      @basic = Card.find_by_name 'Basic' #+*type+*default'
      @r1 = Role.find_by_codename 'r1'
      @basic.permit(:create, @r1)
      @basic.save!
      @ctd = Card.find_by_name 'Cardtype D'
      @cte = Card.find_by_name 'Cardtype E'
    end

    it "should update the basic cardtype's create permission" do
      @basic.who_can(:create).should== @r1
    end
  end
end
