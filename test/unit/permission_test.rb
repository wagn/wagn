require File.dirname(__FILE__) + '/../test_helper'
module Card
  class Base
    def writeable_by(user)
      ::User.as(user) do
        ok? :edit
      end
    end
    
    def readable_by(user)
      ::User.as(user) do
        ok? :read
      end
    end
    
    def appendable_by(user)
      ::User.as(user) do
        ok? :append
      end
    end 
  end
end
 

class PermissionTest < Test::Unit::TestCase
  common_fixtures
  test_helper :permission
  
  def setup
    setup_default_user 
    @u1, @u2, @u3 = %w( u1 u2 u3 ).map do |x| ::User.find_by_login(x) end
    @r1, @r2, @r3 = %w( r1 r2 r3 ).map do |x| ::Role.find_by_codename(x) end
    @c1, @c2, @c3 = %w( c1 c2 c3 ).map do |x| Card.find_by_name(x) end
  end      


  def test_create_connections
    a, b, c, d = create_cards %w( a b c d )

    a.save; a=Card.find_by_name('a');a.permit(:read, @r1); 
    b.save; b=Card.find_by_name('b');b.permit(:read, @r2); 
    a.save!; a=Card.find_by_name('a');
    b.save!; b=Card.find_by_name('b');

    #private cards can't be connected to private cards with a different group
    ab =  a.connect b
    assert ab.errors.on(:permissions), "a+b should have error on reader"
    
    ba = b.connect a 
    assert ba.errors.on(:permissions), "b+a should have error on reader"

    #private cards connected to non-private are private with the same group    
    ac = a.connect c
    ac = Card.find_by_name 'a+c'
    assert_equal ac.who_can(:read), ac.reader, "reader (#{ac.reader.codename}) and who can read (#{ac.who_can(:read).codename}) should be same for card #{ac.name}"
    assert_equal ac.reader, @r1, "a+c should be restricted to r1 too"
    
    warn "ac reader #{ac.reader.codename}"
    c = Card['c']
    c.permit :read, Role[:anon]
    c.save!
    assert_equal c.reader.codename, 'anon', " c should still be set to Anyone"
    
  end
  
  
  def test_reader_setting
    Card.find(:all).each do |c|
      assert_equal c.who_can(:read), c.reader, "reader (#{c.reader}) and who can read (#{c.who_can(:read)}) should be same for card #{c.name}"
    end
  end

=begin
  def test_write_user_permissions
    @u1.roles = [ @r1, @r2 ]
    @u2.roles = [ @r1, @r3 ]
    @u3.roles = [ @r1, @r2, @r3 ]

    as(@admin) { @c1.permit(:edit, @u1); @c1.save }
    as(@admin) { @c2.permit(:edit, @u2); @c2.save }
 
    assert_not_locked_from( @u1, @c1 )
    assert_locked_from( @u2, @c1 )    
    assert_locked_from( @u3, @c1 )    
    
    assert_locked_from( @u1, @c2 )
    assert_not_locked_from( @u2, @c2 )    
    assert_locked_from( @u3, @c2 )    
  end

  def test_should_not_allowed_reader_change
    a, ab, abc, ad = %w(A A+B A+B+C A+D ).collect do |name|  Card.find_by_name(name)  end
      
    abc.permit(:read, @r2); abc.save 

    # now try to change read permissions to a role that would result in conflict
    a.permissions= [:read,:edit,:comment,:delete].map{|t| Permission.new(:task=>t.to_s, :party=>@r1)}
    #assert_raises(Card::PermissionDenied) do
      a.save
    #end
    assert a.errors.on(:permissions)
  end

  def test_create_connections
    a, b, c, d = create_cards %w( a b c d )

    a.save; a=Card.find_by_name('a');a.permit(:read, @r1); 
    b.save; b=Card.find_by_name('b');b.permit(:read, @r2); 
    a.save; a=Card.find_by_name('a');
    b.save; b=Card.find_by_name('b');

    #private cards can't be connected to private cards with a different group
    ab =  a.connect b
    assert ab.errors.on(:permissions), "a+b should have error on reader"
    
    ba = b.connect a 
    assert ba.errors.on(:permissions), "b+a should have error on reader"

    #private cards connected to non-private are private with the same group    
    ac = a.connect c
    ac = Card.find_by_name 'a+c'
    assert_equal a.reader, ac.reader
  end  
     
 
  def test_read_group_permissions
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
  

  def test_write_group_permissions
    @c1.permit(:edit,@r1); @c1.save
    @c2.permit(:edit,@r2); @c2.save
    @c3.permit(:edit,@r3); @c3.save

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

  def test_read_user_permissions
    @u1.roles = [ @r1, @r2 ]
    @u2.roles = [ @r1, @r3 ]
    @u3.roles = [ @r1, @r2, @r3 ]

    as(@admin) { @c1.permit(:read, @u1); @c1.save }
    as(@admin) { @c2.permit(:read, @u2); @c2.save }

    assert_not_hidden_from( @u1, @c1 )
    assert_hidden_from( @u2, @c1 )    
    assert_hidden_from( @u3, @c1 )    
    
    assert_hidden_from( @u1, @c2 )
    assert_not_hidden_from( @u2, @c2 )    
    assert_hidden_from( @u3, @c2 )    
  end





 
          
  def test_should_cascade_reader_change 
    a, ab, abc, ad = %w(A A+B A+B+C A+D ).collect do |name|  Card.find_by_name(name)  end
    a.permit(:read,@r1); a.save
    assert_equal a.reader,  ab.reload.reader
    assert_equal a.reader, abc.reload.reader
    assert_equal a.reader,  ad.reload.reader
  end




 
  def test_should_allow_reader_change_on_existing_connections
    a, ab, abc, ad = %w(A A+B A+B+C A+D ).collect do |name|  Card.find_by_name(name)  end
    a.permit(:read, @r1); a.save
    
    # assert that cards of which a is a part have also been changed
    assert_equal a.reader,  ab.reload.reader
    assert_equal a.reader, abc.reload.reader
    assert_equal a.reader,  ad.reload.reader

    # now change it again.  should still work
    a.permit(:read, @r2); a.save
    
    # assert that cards of which a is a part have also been changed
    assert_equal a.reader,  ab.reload.reader
    assert_equal a.reader, abc.reload.reader
    assert_equal a.reader,  ad.reload.reader
  end
          
  def test_anon_user_should_exist
    assert_instance_of User, User.find_by_login('anon')
  end
 

  def test_private_wql
    # set up cards of type TestType, 2 with nil reader, 1 with role1 reader 
     as(@admin) do 
       [@c1,@c2,@c3].each do |c| 
         c.update_attribute(:content, 'WeirdWord')
         c.save
         c.permit(:read, Role.find_by_codename('anon'))    #fixme -- this should be done by setting the cardtype perms
       end
       @c1.permit(:read,@u1); @c1.save
     end
  
     as(@u1) do
       assert_equal %w( c1 c2 c3 ), Card.find_by_wql_options(:keyword=>'WeirdWord').plot(:name).sort
     end
     as(@u2) do
       assert_equal %w( c2 c3 ), Card.find_by_wql_options(:keyword=>'WeirdWord').plot(:name).sort
     end
  end

  def test_role_wql
    @r1.users = [ @u1 ]

    # set up cards of type TestType, 2 with nil reader, 1 with role1 reader 
    as(@admin) do 
      [@c1,@c2,@c3].each do |c| 
        c.update_attribute(:content, 'WeirdWord')
        c.save
        c.permit(:read, Role.find_by_codename('anon'))    
      end
      @c1.permit(:read, @r1); @c1.save
    end

    as(@u1) do
      assert_equal %w( c1 c2 c3 ), Card.find_by_wql_options(:keyword=>'WeirdWord').plot(:name).sort
    end
    as(@u2) do
      assert_equal %w( c2 c3 ), Card.find_by_wql_options(:keyword=>'WeirdWord').plot(:name).sort
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
=end
end
