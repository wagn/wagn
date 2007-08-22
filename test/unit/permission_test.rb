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
  
  # test that you can't change group on a card that you can't get it back from.
   # for each user, for each group, try assigning each card to that group and then changing back.
   def test_cant_put_yourself_in_a_corner
     @r2.tasks='manage_roles,edit_cards'; @r2.save
     @r1.users = [ @u1, @u2, @u3 ]
     @r2.users = [ @u1, @u2 ]
     @r3.users = [ @u1 ]
     roles = Role.find(:all)
     User.find(:all).reject{|u|u.login=='hoozebot' or u.login=='wagbot'}.each do |user|
       User.as(@admin) do @c1.reader = @c1.writer = nil; @c1.save! end
       User.as(user) do 
         roles.each do |role|
           begin 
             @c1.reader = role  
             @c1.save!
             assert_not_hidden_from( user, @c1, "#{user.login} reader #{role.cardname}" )
           rescue Wagn::PermissionDenied 
           end

           begin
             @c1.writer = role
             @c1.save!
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

  def test_create_connections
    a, b, c, d = create_cards %w( a b c d )

    a.reader = @r1; a.save
    b.reader = @r2; b.save

    #private cards can't be connected to private cards with a different group
    ab =  a.connect b
    assert ab.errors.on(:reader), "a+b should have error on reader"
    
    ba = b.connect a 
    assert ba.errors.on(:reader), "b+a should have error on reader"

    #private cards connected to non-private are private with the same group    
    ac = a.connect c
    assert_equal a.reader, ac.reader
  end  

  def test_write_group_permissions
    @c1.writer = @r1; @c1.save
    @c2.writer = @r2; @c2.save
    @c3.writer = @r3; @c3.save

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
 
  def test_should_start_with_nil_reader_and_writer
    %w( A B C D A+B A+B+C A+D ).each do |name| 
      c = Card.find_by_name(name)
      assert_equal nil, c.reader, "#{c.name} starts with nil reader"
      assert_equal nil, c.writer, "#{c.name} starts with nil writer"
      assert_equal nil, c.appender, "#{c.name} starts with nil appender"
    end
  end
          
  def test_should_cascade_reader_change 
    a, ab, abc, ad = %w(A A+B A+B+C A+D ).collect do |name|  Card.find_by_name(name)  end
    a.reader = @r1; a.save
    assert_equal a.reader,  ab.reload.reader
    assert_equal a.reader, abc.reload.reader
    assert_equal a.reader,  ad.reload.reader
  end


  def test_should_not_allowed_reader_change
    a, ab, abc, ad = %w(A A+B A+B+C A+D ).collect do |name|  Card.find_by_name(name)  end
    abc.reader = @r2; abc.save 
    # now try to change role that would result in conflict
    a.reader = @r1
    a.save
    assert a.errors.on(:reader)
  end  


 
  def test_should_allow_reader_change_on_existing_connections
    a, ab, abc, ad = %w(A A+B A+B+C A+D ).collect do |name|  Card.find_by_name(name)  end
    a.reader = @r1; a.save
    
    # assert that cards of which a is a part have also been changed
    assert_equal a.reader,  ab.reload.reader
    assert_equal a.reader, abc.reload.reader
    assert_equal a.reader,  ad.reload.reader

    # now change it again.  should still work
    a.reader = @r2; a.save
    
    # assert that cards of which a is a part have also been changed
    assert_equal a.reader,  ab.reload.reader
    assert_equal a.reader, abc.reload.reader
    assert_equal a.reader,  ad.reload.reader
  end
          
  def test_anon_user_should_exist
    assert_instance_of User, User.find_by_login('anon')
  end
          
  def test_anon_should_not_get_authenticated_permissions
    User.as(User.find_by_login('anon')) do
      assert !System.ok?(:edit_cards)
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
      assert_equal %w( c1 c2 c3 ), Card.find_by_wql_options(:type=>'TestType').plot(:name).sort
    end
    as(@u2) do
      assert_equal %w( c2 c3 ), Card.find_by_wql_options(:type=>'TestType').plot(:name).sort
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
       assert_equal %w( c1 c2 c3 ), Card.find_by_wql_options(:type=>'TestType').plot(:name).sort
     end
     as(@u2) do
       assert_equal %w( c2 c3 ), Card.find_by_wql_options(:type=>'TestType').plot(:name).sort
     end
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
