require File.dirname(__FILE__) + '/../../spec_helper'

=begin
# WE STOPPED ENFORCING THIS RULE!
describe Card, "New Connection Card with two differently restricted pieces" do
  before do
    User.as :wagbot 
    c = Card['c']; c.permit :read, Role['r1']; c.save!    
    d = Card['d']; d.permit :read, Role['r2']; d.save!    
    @cd = Card.create :name=>'c+d'
  end
  
  it "should not be allowed to make this restriction" do
    @cd.errors.on(:permissions).should_not be_nil
    #warn "errors: #{@cd.errors.inspect}"
  end
end
=end


describe Card, "New Connection Card with one restricted piece" do
  before do
    User.as :wagbot 
    c = Card['c']
    c.permit :read, Role['r1']
    c.save!    
    @cd = Card.create! :name=>'c+d'
  end
  
  it "should be restricted to the same party" do
    @cd.who_can(:read).should == Role['r1']
  end
end

describe Card, "Piece Card with new restriction" do
  before do
    User.as :wagbot 
    @cd = Card.create! :name=>'c+d'
    c = Card['c']
    c.permit :read, Role['r1']
    c.save!
  end
  
  it "should show the restriction change" do
    Card['c'].who_can(:read).should == Role['r1']
  end
  it "should restrict its connections." do
    Card['c+d'].who_can(:read).should == Role['r1']
  end
end


describe Card, "Piece of Connection Card with restriction" do
  before do
    User.as :wagbot 
    @cd = Card.create :name=>'c+d'
    @cd.permit :read, Role['r2']
    @cd.save!
    @c = Card['c']
  end
  
  it "should be possible to set it to Anyone" do
    @c.permit :read, Role[:anon]
    @c.save
    @c.errors.on(:permissions).should == nil
  end

  it "should be possible to set it to the same party as the connection card restriction" do
    @c.permit :read, Role['r2']
    @c.save
    @c.errors.on(:permissions).should == nil
  end
end

    
describe Card, "new permissions" do
  User.as :joe_user
  
  it "should let joe view new cards" do
    @c = Card.new
    @c.ok?(:read).should be_true
  end

  it "should let joe render content of new cards" do
    @c = Card.new
    Renderer.new.render(@c).should == ''
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
    User.as :wagbot 
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
    User.as :wagbot 
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
    User.as :wagbot 
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
