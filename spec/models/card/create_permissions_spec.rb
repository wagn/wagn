require File.dirname(__FILE__) + '/../../spec_helper'


describe Card, "sets permissions correctly by default" do
  before do
    User.as :joe_user
    #@defaults = [:read,:edit,:comment,:delete].map{|t| Permission.new(:task=>t.to_s, :party=>::Role.find_by_codename('auth'))}
    @c = Card.create! :name=>"temp card"
  end
  
  it "should set default permissions immediately upon creation" do
#    warn "PERMISSIONS: #{Card.template('temp card').inspect}"
#    warn "Basic template: #{Card['Basic+*type+*default'].inspect}"
    @c.permissions.length.should==3
  end
  
  it "should preserve permissions setting after reload" do
    Card.find_by_name('temp card').permissions.length.should==3
  end
end


describe Card, "normal user create permissions" do
  before do
    User.as :joe_user
  end
  it "should allow anyone signed in to create Basic Cards" do
    Card::Basic.create_ok?.should be_true
  end
end

describe Card, "anonymous create permissions" do
  before do
    User.as :anon
  end
  it "should not allow someone not signed in to create Basic Cards" do
    Card::Base.create_ok?.should_not be_true
  end
end
        

