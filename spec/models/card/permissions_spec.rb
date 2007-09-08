require File.dirname(__FILE__) + '/../../spec_helper'



       
describe Card, "new permissions" do
  User.as :joe_user
  
  it "should let joe view new cards" do
    @c = Card.new
    @c.send(:set_defaults)
    @c.ok?(:read).should be_true
  end

  it "should let joe render content of new cards" do
    @c = Card.new
    @c.send(:set_defaults)
    Renderer.instance.render(@c).should == ''
  end

end


describe Card, "default permissions" do
  before do
    User.as :joe_user do
      @c = Card.create! :name=>"sky blue"
    end
  end
  
  it "should let anonymous users view basic cards" do
    User.as :anon
    @c.ok?(:read).should be_true
  end
  
  it "should let joe view basic cards" do
    User.as :joe_user
    @c.ok?(:read).should be_true
  end
end

describe Card, "updating permissions" do
  before do
    User.as :admin
    @anon = Role.find_by_codename 'anon'
    @auth = Role.find_by_codename 'auth'
    @perms = [:read,:edit,:comment,:delete].map{|t| ::Permission.new(:task=>t.to_s, :party=>@anon)}
    @c = Card.find_by_name 'X'
    @c.permissions=@perms
    @c.save!
  end
  
  it "should give permissions to auth after setting permissions" do
    @c.permissions.find_by_task('read').party.should== @anon
  end
  
  it "should set the reader in the process" do
    @c.who_can(:read).should== @anon
  end
  it "should retain these permissions after a hard reload" do
    @c = Card.find_by_name 'X'
    @c.permissions.find_by_task('read').party.should== @anon
  end
end


describe Card, "Permit method on existing card" do
  before do
    User.as :admin
    @c = Card.find_by_name 'X'
    @r2 = Role.find_by_codename 'r2'
    @c.permit(:read, @r2)
    @c.save!
  end
  
  it "should give permissions after setting permissions" do
     @c.permissions.find_by_task('read').party.should== @r2
   end
  it "should immediately be ok to read" do
    @c.who_can(:read).should== @r2
  end
  it "should still work after reload" do
    @c = Card.find_by_name 'X'
    @c.who_can(:read).should== @r2
  end
  it "should update reader" do
    @c.who_can(:read) == @r2
  end
  it "should update reader -- even after reload" do
    @c = Card.find_by_name 'X'
    @c.who_can(:read) == @r2
  end
end  

describe Card, "Permit method on new card" do
  before do
    User.as :admin
    @c = Card.create :name=>'New Bee'
    @r2 = Role.find_by_codename 'r2'
    @c.permit(:read, @r2)
    @c.save
  end
  
  it "should give permissions after setting permissions" do
     @c.permissions.find_by_task('read').party.should== @r2
   end
  it "should immediately be ok to read" do
    @c.who_can(:read).should== @r2
  end
  it "should still work after reload" do
    @c = Card.find_by_name 'New Bee'
    @c.who_can(:read).should== @r2
  end
  it "should update reader" do
    @c.who_can(:read) == @r2
  end
end


          
# FIXME-perm

# need test for
# changing cardtypes gives you correct permissions (changing cardtype in general...)
