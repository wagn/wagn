require File.dirname(__FILE__) + '/../../spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../../permission_spec_helper')

describe "reader keys" do
  before do
    User.as(:wagbot) do
      @card = Card.fetch('Home')
      @perm_card = Card.create(:name=>'Home+*self+*read', :type=>'Pointer', :content=>'[[Anyone]]')
      @anyone_id = Card.fetch('Anyone').id
      @anon_id = Card.fetch('Anonymous').id
    end
  end
  
  it "should handle role" do
    @card.generate_reader_key.should == "G#{@anyone_id}"
  end
  
  it "should handle user" do
    User.as(:wagbot) do
      @perm_card.content = '[[Anonymous]]'
      @perm_card.save!
      @card.generate_reader_key.should == "I#{@anon_id}"
    end
  end
  
end

describe "Permission", ActiveSupport::TestCase do
  before do
    User.as( :wagbot )
    @u1, @u2, @u3 = %w( u1 u2 u3 ).map do |x| ::User.find_by_login(x) end
    @r1, @r2, @r3 = %w( r1 r2 r3 ).map do |x| ::Role[x] end
    @c1, @c2, @c3 = %w( c1 c2 c3 ).map do |x| Card.find_by_name(x) end
  end      


  it "checking ok read should not add to errors" do
    h = nil
    User.as(:joe_admin) do
      h = Card.create! :name=>"Hidden"
      Card.create(:name=>'Hidden+*self+*read', :type=>'Pointer', :content=>'[[Anyone Signed In]]')
    end
  
    User.as(:anon) do
      h.ok?(:read).should == false
      h.errors.empty?.should_not == nil
    end
  end   

  it "reader setting" do
    Card.find(:all).each do |c|
      c.setting_card(:read).id.should == c.reader_rule_id
    end
  end

  it "write user permissions" do
    @u1.roles = [ @r1, @r2 ]
    @u2.roles = [ @r1, @r3 ]
    @u3.roles = [ @r1, @r2, @r3 ]

    ::User.as(:wagbot) {
      [1,2,3].each do |num|
        Card.create(:name=>"c#{num}+*self+*update", :type=>'Pointer', :content=>"[[u#{num}]]")
      end 
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
    
    ::User.as(:wagbot) do
      [1,2,3].each do |num|
        Card.create(:name=>"c#{num}+*self+*read", :type=>'Pointer', :content=>"[[r#{num}]]")
      end
    end
    
    assert_not_hidden_from( @u1, @c1 )
    assert_not_hidden_from( @u1, @c2 )
    assert_hidden_from( @u1, @c3 )    
    
    assert_not_hidden_from( @u2, @c1 )
    assert_hidden_from( @u2, @c2 )    
    assert_not_hidden_from( @u2, @c3 )    
  end

  it "write group permissions" do
    [1,2,3].each do |num|
      Card.create(:name=>"c#{num}+*self+*update", :type=>'Pointer', :content=>"[[r#{num}]]")
    end
    
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
      [1,2,3].each do |num|
        Card.create(:name=>"c#{num}+*self+*read", :type=>'Pointer', :content=>"[[u#{num}]]")
      end
    }


    # NOTE: retrieving private cards is known not to work now.      
    # assert_not_hidden_from( @u1, @c1 )
    # assert_not_hidden_from( @u2, @c2 )    
    
    assert_hidden_from( @u2, @c1 )    
    assert_hidden_from( @u3, @c1 )    
    assert_hidden_from( @u1, @c2 )
    assert_hidden_from( @u3, @c2 )    
  end
  

  it "private wql" do
    # set up cards of type TestType, 2 with nil reader, 1 with role1 reader 
     ::User.as(:wagbot) do 
       [@c1,@c2,@c3].each do |c| 
         c.update_attribute(:content, 'WeirdWord')
       end
       Card.create(:name=>"c1+*self+*read", :type=>'Pointer', :content=>"[[u1]]")
     end
  
     ::User.as(@u1) do
       Card.search(:content=>'WeirdWord').plot(:name).sort.should == %w( c1 c2 c3 )
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
      end
      Card.create(:name=>"c1+*self+*read", :type=>'Pointer', :content=>"[[r1]]")
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



    
describe Card, "new permissions" do
  User.as :joe_user
  
  it "should let joe view new cards" do
    @c = Card.new
    @c.ok?(:read).should be_true
  end

  it "should let joe render content of new cards" do
    @c = Card.new
    Renderer.new(@c).render.should be_html_with do
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
    User.as :anon do
      @c.ok?(:read).should be_true
    end
  end
  
  it "should let joe view basic cards" do
    User.as :joe_user do
      @c.ok?(:read).should be_true
    end
  end
  
end



describe Card, "settings based permissions" do
  before do
    User.as :wagbot
    @delete_setting_card = Card.fetch_or_new '*all+*delete'
    @delete_setting_card.type = 'Pointer'
    @delete_setting_card.content = '[[Joe_User]]'
    @delete_setting_card.save!
  end
  
  it "should handle delete as a setting" do
    c = Card.new :name=>'whatever'
    c.who_can(:delete).should == ['joe_user']
    User.as :joe_user
    c.ok?(:delete).should == true
    User.as :u1
    c.ok?(:delete).should == false
    User.as :anon
    c.ok?(:delete).should == false
    User.as :wagbot
    c.ok?(:delete).should == true #because administrator
  end
end



# FIXME-perm

# need test for
# changing cardtypes gives you correct permissions (changing cardtype in general...)
