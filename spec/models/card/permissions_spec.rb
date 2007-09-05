require File.dirname(__FILE__) + '/../../spec_helper'



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
       
describe Card, "new permissions" do
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
    @c.reader.should== @anon
  end
  it "should retain these permissions after a hard reload" do
    @c = Card.find_by_name 'X'
    @c.permissions.find_by_task('read').party.should== @anon
  end
end


describe Card, "hacky permission api" do
  before do
    User.as :admin
    @c = Card.find_by_name 'X'
    @r2 = Role.find_by_codename 'r2'
    @c.permit(:read, @r2)
  end
  
  it "should give permissions after setting permissions" do
     @c.permissions.find_by_task('read').party.should== @r2
   end
  it "should immediately be ok to read" do
    @c.ok? :read
  end
  it "should still work after reload" do
    @c = Card.find_by_name 'X'
    @c.ok? :read
  end
  it "should update reader" do
    @c.reader == @r2
  end
end  
  
          
# FIXME-perm

# need test for
# changing cardtypes gives you correct permissions (changing cardtype in general...)

# permit() sets reader immediately

# creation uses template settings.