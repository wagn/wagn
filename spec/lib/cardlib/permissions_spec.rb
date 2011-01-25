require File.dirname(__FILE__) + '/../../spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../../permission_spec_helper')

describe "Permission", ActiveSupport::TestCase do
  before do
    User.as( :wagbot )
    @u1, @u2, @u3 = %w( u1 u2 u3 ).map do |x| ::User.find_by_login(x) end
    @r1, @r2, @r3 = %w( r1 r2 r3 ).map do |x| ::Role[x] end
    @c1, @c2, @c3 = %w( c1 c2 c3 ).map do |x| Card.find_by_name(x) end
  end      

=begin
  it "create connections" do
    a = Card.create! :name=>'a44'
    a.permit(:read, @r1); a.save!
    b = Card.create! :name=>'b44'
    b.permit(:read, @r2); b.save! 

    #private cards can't be connected to private cards with a different group
    ab = Card.create :name=>'a44+b44'
    ab.permit :read, ::Role[:anon]
    ab.save
    ab.errors.on(:permissions).should_not == nil
    
    ba = Card.create :name=>'b44+a44'
    ba.errors.on(:permissions).should_not == nil

    #private cards connected to non-private are private with the same group    
    ac = Card.create :name=>'a44+c44'
    ac.reader.should == a.reader
  end
=end


  it "create connections" do
    a, b, c, d = [ 
      Card.create!( :name=> "a33" ),
      Card.create!( :name=> "b33" ),
      Card.create!( :name=> "c33" ),
      Card.create!( :name=> "d33" )
    ]

    a.save; a=Card.find_by_name('a33');a.permit(:read, @r1); 
    b.save; b=Card.find_by_name('b33');b.permit(:read, @r2); 
    a.save; a=Card.find_by_name('a33');
    b.save; b=Card.find_by_name('b33');

    #private cards connected to non-private are private with the same group    
    ac = Card.create :name=>'a33+c33'
    assert_equal ac.who_can(:read), ac.reader, "reader (#{ac.reader.codename}) and who can read (#{ac.who_can(:read).codename}) should be same for card #{ac.name}"
    assert_equal ac.reader, @r1, "a+c should be restricted to r1 too"

    c = Card['c33']
    c.permit :read, Role[:anon]
    c.save
    assert_equal c.reader.codename, 'anon', " c should still be set to Anyone"
  end

  it "checking ok read should not add to errors" do
    User.as(:joe_admin)
    h = Card.create! :name=>"Hidden"
    h.permit(:read, Role[:auth])   
    h.save!
  
    User.as(:anon)
    h = Card["Hidden"]
    h.ok?(:read)
    h.errors.empty?.should_not == nil
  end   

  it "reader setting" do
    Card.find(:all).each do |c|
      who = c.who_can(:read)
      assert_equal who, c.reader, "reader (#{c.reader.codename}) and who can read (#{who.codename}) should be same for card #{c.name}"
    end
  end

  it "write user permissions" do
    @u1.roles = [ @r1, @r2 ]
    @u2.roles = [ @r1, @r3 ]
    @u3.roles = [ @r1, @r2, @r3 ]

    ::User.as(:wagbot) { 
      @c1.permit(:edit, @u1); @c1.save
      @c2.permit(:edit, @u2); @c2.save 
    }
 
    assert_not_locked_from( @u1, @c1 )
    assert_locked_from( @u2, @c1 )    
    assert_locked_from( @u3, @c1 )    
    
    assert_locked_from( @u1, @c2 )
    assert_not_locked_from( @u2, @c2 )    
    assert_locked_from( @u3, @c2 )    
  end
 
  it "read group permissions" do
    @u1.roles = [ @r1, @r2 ]; @u1.save;
    @u2.roles = [ @r1, @r3 ]; @u2.save;

    @c1.permit(:read, @r1); @c1.save
    @c2.permit(:read, @r2); @c2.save
    @c3.permit(:read, @r3); @c3.save

    assert_not_hidden_from( @u1, @c1 )
    assert_not_hidden_from( @u1, @c2 )
    assert_hidden_from( @u1, @c3 )    
    
    assert_not_hidden_from( @u2, @c1 )
    assert_hidden_from( @u2, @c2 )    
    assert_not_hidden_from( @u2, @c3 )    
  end

  it "write group permissions" do
    @c1.permit(:edit,@r1); @c1.save
    @c2.permit(:edit,@r2); @c2.save
    @c3.permit(:edit,@r3); @c3.save
    
    @u3.roles = [ @r1 ]  #not :admin here

    %{        u1 u2 u3
      c1(r1)  T  T  T
      c2(r2)  T  T  F
      c3(r3)  T  F  F
    }
    assert_equal true,  @c1.writeable_by(@u1), "c1 writeable by u1"
    assert_equal true,  @c1.writeable_by(@u2), "c1 writeable by u2" 
    assert_equal true,  @c1.writeable_by(@u3), "c1 writeable by u3" 
    assert_equal true,  @c2.writeable_by(@u1), "c2 writeable by u1" 
    assert_equal true,  @c2.writeable_by(@u2), "c2 writeable by u2" 
    assert_equal false, @c2.writeable_by(@u3), "c2 writeable by u3" 
    assert_equal true,  @c3.writeable_by(@u1), "c3 writeable by u1" 
    assert_equal false, @c3.writeable_by(@u2), "c3 writeable by u2" 
    assert_equal false, @c3.writeable_by(@u3), "c3 writeable by u3" 
  end

  it "read user permissions" do
    @u1.roles = [ @r1, @r2 ]
    @u2.roles = [ @r1, @r3 ]
    @u3.roles = [ @r1, @r2, @r3 ]

    ::User.as(:wagbot) { 
      @c1.permit(:read, @u1); @c1.save 
      @c2.permit(:read, @u2); @c2.save 
    }


    # NOTE: retrieving private cards is known not to work now.      
    # assert_not_hidden_from( @u1, @c1 )
    # assert_not_hidden_from( @u2, @c2 )    
    
    assert_hidden_from( @u2, @c1 )    
    assert_hidden_from( @u3, @c1 )    
    assert_hidden_from( @u1, @c2 )
    assert_hidden_from( @u3, @c2 )    
  end
          
  it "should cascade reader change" do 
    a, ab, abc, ad = %w(A A+B A+B+C A+D ).collect do |name|  Card.find_by_name(name)  end
    a.permit(:read,@r1); a.save
    ab.reload.reader.should == a.reader
    abc.reload.reader.should == a.reader
    ad.reload.reader.should == a.reader
  end

  it "should allow reader change on existing connections" do
    a, ab, abc, ad = %w(A A+B A+B+C A+D ).collect do |name|  Card.find_by_name(name)  end
    a.permit(:read, @r1); a.save
    
    # assert that cards of which a is a part have also been changed
    ab.reload.reader.should == a.reader
    abc.reload.reader.should == a.reader
    ad.reload.reader.should == a.reader

    # now change it again.  should still work
    a.permit(:read, @r2); a.save
    
    # assert that cards of which a is a part have also been changed
    ab.reload.reader.should == a.reader
    abc.reload.reader.should == a.reader
    ad.reload.reader.should == a.reader
  end
          
  it "anon user should exist" do
    assert_instance_of User, User.find_by_login('anon')
  end
 

  it "private wql" do
    # set up cards of type TestType, 2 with nil reader, 1 with role1 reader 
     ::User.as(:wagbot) do 
       [@c1,@c2,@c3].each do |c| 
         c.update_attribute(:content, 'WeirdWord')
         c.save
         c.permit(:read, Role[:anon])    #fixme -- this should be done by setting the cardtype perms
       end
       @c1.permit(:read,@u1); @c1.save
     end
  
     ::User.as(@u1) do
       # NOTE: retrieving private cards is known not to work now.      
       Card.search(:content=>'WeirdWord').plot(:name).sort.should == %w( c2 c3 )
       #assert_equal %w( c1 c2 c3 ), Card.search(:content=>'WeirdWord').plot(:name).sort
     end
     ::User.as(@u2) do
       Card.search(:content=>'WeirdWord').plot(:name).sort.should == %w( c2 c3 )
     end
  end

  it "role wql" do
    @r1.users = [ @u1 ]

    # set up cards of type TestType, 2 with nil reader, 1 with role1 reader 
    ::User.as(:wagbot) do 
      [@c1,@c2,@c3].each do |c| 
        c.update_attribute(:content, 'WeirdWord')
        c.save
        c.permit(:read, Role[:anon])    
      end
      @c1.permit(:read, @r1); @c1.save
    end

    ::User.as(@u1) do
      Card.search(:content=>'WeirdWord').plot(:name).sort.should == %w( c1 c2 c3 )
    end
    ::User.as(@u2) do
      Card.search(:content=>'WeirdWord').plot(:name).sort.should == %w( c2 c3 )
    end
  end  

  def permission_matrix
    # TODO
    # generate this graph three ways:
    # given a card with editor in group X, can Y edit it?
    # given a card with reader in group X, can Y view it?
    # given c card with group anon, can Y change the reader/writer to X    
    
    # X,Y in Anon, auth Member, auth Nonmember, admin       
    
    %{
  A V C J G
A * * * * *
V * * . * .
C * * * . .
J * * . . .
G * . . . .
}   
    
  end

end


describe Card, "New plus card with one restricted piece" do
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
    Slot.new(@c).render.should be_html_with do
      span(:class=>"open-content content editOnDoubleClick") {}
    end
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
    @anon = Role[:anon]
    @auth = Role[:auth]
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
    @r2 = Role['r2']
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
    @r2 = Role['r2']
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
