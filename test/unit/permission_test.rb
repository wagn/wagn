require File.dirname(__FILE__) + '/../test_helper'
class PermissionTest < Test::Unit::TestCase
  common_fixtures
  test_helper :permission
  
  def setup
    setup_default_user 
    as(@admin) do
      @u1, @u2, @u3 = create_users %w( u1 u2 u3 ) 
      @r1, @r2, @r3 = create_roles %w( r1 r2 r3 )
      @c1, @c2, @c3 = create_cards %w( c1 c2 c3 )
    end
  end

  def test_role_wql
    @r1.users = [ @u1 ]

    # set up cards of type TestType, 2 with nil reader, 1 with role1 reader 
    Card::Cardtype.create(:name=>'TestType')
    as(@admin) do 
      [@c1,@c2,@c3].each do |c| 
        c.update_attribute(:type, 'TestType')
        c.reader=nil    
        c.save
      end
      @c1.reader = @r1; @c1.save
    end

    as(@u1) do
      assert_equal %w( c1 c2 c3 ), Card.find_by_wql_options(:cardtype=>'TestType').plot(:name).sort
    end
    as(@u2) do
      assert_equal %w( c2 c3 ), Card.find_by_wql_options(:cardtype=>'TestType').plot(:name).sort
    end
  end  
        
  def test_private_wql
    # set up cards of type TestType, 2 with nil reader, 1 with role1 reader 
     Card::Cardtype.create(:name=>'TestType')
     as(@admin) do 
       [@c1,@c2,@c3].each do |c| 
         c.update_attribute(:type, 'TestType')
         c.reader=nil    
         c.save
       end
       @c1.reader = @u1; @c1.save
     end

     as(@u1) do
       assert_equal %w( c1 c2 c3 ), Card.find_by_wql_options(:cardtype=>'TestType').plot(:name).sort
     end
     as(@u2) do
       assert_equal %w( c2 c3 ), Card.find_by_wql_options(:cardtype=>'TestType').plot(:name).sort
     end
  end
  
  def test_cant_put_yourself_in_a_corner
    @r2.tasks='manage_roles,edit_cards'; @r2.save
    @r1.users = [ @u1, @u2, @u3 ]
    @r2.users = [ @u1, @u2 ]
    @r3.users = [ @u1 ]
    roles = Role.find(:all)
    User.find(:all).reject{|u|u.login=='hoozebot' or u.login=='wagbot'}.each do |user|
      as(@admin) do @c1.reader = nil; @c1.writer=nil; @c1.save end
      as(user) do 
        roles.each do |role|
          begin 
            @c1.reader = role
            assert_not_hidden_from( user, @c1, "#{user.login} reader #{role.cardname}" )
          rescue Wagn::PermissionDenied 
          end
          
          begin
            @c1.writer = role
            #warn "#{user.login} -> #{role.cardname} granted.  set to #{ @c1.writer ? @c1.writer.cardname : ''}" 
            assert_not_locked_from( user, @c1, "#{user.login} writer #{@c1.writer ? @c1.writer.cardname : ''}" )
          rescue Wagn::PermissionDenied => e
            #warn "#{user.login} -> #{role.cardname} denied. #{e.message}"
            #reset to #{ @c1.writer ? @c1.writer.cardname : ''}" 
          end
        end
      end
    end
  end

  def test_creation_defaults
    a, b, ab = create_cards %w( a b a+b )
    
    assert_equal nil, a.reader,  "reader starts empty" 
    assert_equal nil, b.reader,  "reader starts empty" 
    assert_equal nil, ab.reader, "reader starts empty" 
    
    assert_equal nil, a.writer,  "writer starts empty" 
    assert_equal nil, b.writer,  "writer starts empty" 
    assert_equal nil, ab.writer, "writer starts empty" 
  end
  
  def test_read_group_permissions
    @u1.roles = [ @r1, @r2 ]
    @u2.roles = [ @r1, @r3 ]

    @c1.reader = @r1; @c1.save
    @c2.reader = @r2; @c2.save
    @c3.reader = @r3; @c3.save

    assert_not_hidden_from( @u1, @c1 )
    assert_not_hidden_from( @u1, @c2 )    
    assert_hidden_from( @u1, @c3 )    
    
    assert_not_hidden_from( @u2, @c1 )
    assert_hidden_from( @u2, @c2 )    
    assert_not_hidden_from( @u2, @c3 )    
  end

  def test_read_user_permissions
    @u1.roles = [ @r1, @r2 ]
    @u2.roles = [ @r1, @r3 ]
    @u3.roles = [ @r1, @r2, @r3 ]

    as(@admin) { @c1.reader = @u1; @c1.save }
    as(@admin) { @c2.reader = @u2; @c2.save }

    assert_not_hidden_from( @u1, @c1 )
    assert_hidden_from( @u2, @c1 )    
    assert_hidden_from( @u3, @c1 )    
    
    assert_hidden_from( @u1, @c2 )
    assert_not_hidden_from( @u2, @c2 )    
    assert_hidden_from( @u3, @c2 )    
  end

  def test_write_group_permissions
    @u1.roles = [ @r1, @r2 ]
    @u2.roles = [ @r1, @r3 ]

    @c1.writer = @r1; @c1.save
    @c2.writer = @r2; @c2.save
    @c3.writer = @r3; @c3.save

    assert_not_locked_from( @u1, @c1, "u1 c1" )
    assert_not_locked_from( @u1, @c2, "u1 c2" )    
    assert_locked_from( @u1, @c3, "u1 c3" )    
    
    assert_not_locked_from( @u2, @c1, "u2 c1" )
    assert_locked_from( @u2, @c2, "u2 c2" )    
    assert_not_locked_from( @u2, @c3, "u2 c3" )    
  end

  def test_write_user_permissions
    @u1.roles = [ @r1, @r2 ]
    @u2.roles = [ @r1, @r3 ]
    @u3.roles = [ @r1, @r2, @r3 ]

    as(@admin) { @c1.writer = @u1; @c1.save }
    as(@admin) { @c2.writer = @u2; @c2.save }
 
    assert_not_locked_from( @u1, @c1 )
    assert_locked_from( @u2, @c1 )    
    assert_locked_from( @u3, @c1 )    
    
    assert_locked_from( @u1, @c2 )
    assert_not_locked_from( @u2, @c2 )    
    assert_locked_from( @u3, @c2 )    
  end
 
  def test_create_connections
    a, b, c, d = create_cards %w( a b c d )

    a.reader = @r1; a.save
    b.reader = @r2; b.save

    #private cards can't be connected to private cards with a different group
    assert_raises(Wagn::PermissionDenied) {  a.connect!(b) }
    assert_raises(Wagn::PermissionDenied) {  b.connect!(a) }

    #private cards connected to non-private are private with the same group    
    ac = a.connect! c
    assert_equal a.reader, ac.reader
  end  
    
  def test_allowed_reader_change_on_existing_connections
    # create cards with default permissions
    a, b, c, d = create_cards %w( a b c d )
    ab, abc, ad = create_cards %w( a+b a+b+c a+d )
    
    # now change role
    a.reader = @r1; a.save
    
    # assert that cards of which a is a part have also been changed
    assert_equal a.reader,  ab.reload.reader
    assert_equal a.reader, abc.reload.reader
    assert_equal a.reader,  ad.reload.reader
  end

  def test_allowed_writer_change_on_existing_connections
    # create cards with default permissions
    a, b, c, d = create_cards %w( a b c d )
    ab, abc, ad = create_cards %w( a+b a+b+c a+d )
    
    # now change role
    a.writer = @r1; a.save
    
    # assert that cards of which a is a part have also been changed
    assert_equal a.writer,  ab.reload.writer
    assert_equal a.writer, abc.reload.writer
    assert_equal a.writer,  ad.reload.writer

    # now change it again.  should still work
    a.writer = @r2; a.save
    
    # assert that cards of which a is a part have also been changed
    assert_equal a.writer,  ab.reload.writer
    assert_equal a.writer, abc.reload.writer
    assert_equal a.writer,  ad.reload.writer
  end
  
  def test_not_allowed_writer_change_on_existing_connections
    # create cards with default permissions
    a, b, c, d = create_cards %w( a b c d )
    ab, abc, ad = create_cards %w( a+b a+b+c a+d )
    
    # set role on a combo card
    abc.writer = @r2; abc.save 
    
    # now try to change role that would result in conflict
    assert_raises(Wagn::PermissionDenied) { a.writer = @r1; a.save }
  end  

                             
  def permission_matrix
                      
    # TODO
    # generate this graph three ways:
    # given a card with editor in group X, can Y edit it?
    # given a card with reader in group X, can Y view it?
    # given c card with group anon, can Y change the reader/writer to X
    %{
  A V C J C
A * * * * *
V * * . * .
C * * * . .
J * * . . .
G * . . . .
}   
    
  end
  
  
end
