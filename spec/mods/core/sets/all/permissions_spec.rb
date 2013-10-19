# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

class ::Card
  def writeable_by(user)
    Account.as(user.id) do
    #warn "writeable #{Account.as_id}, #{user.inspect}"
      ok? :update
    end
  end

  def readable_by(user)
    Account.as(user.id) do
      ok? :read
    end
  end
end


module PermissionSpecHelper

  def assert_hidden_from( user, card, msg='')
    Account.as(user.id) { assert_hidden( card, msg ) }
  end

  def assert_not_hidden_from( user, card, msg='')
    Account.as(user.id) { assert_not_hidden( card, msg ) }
  end

  def assert_locked_from( user, card, msg='')
    Account.as(user.id) { assert_locked( card, msg ) }
  end

  def assert_not_locked_from( user, card, msg='')
    Account.as(user.id) { assert_not_locked( card, msg ) }
  end

  def assert_hidden( card, msg='' )
    assert_equal [], Card.search(:id=>card.id).map(&:name), msg
  end

  def assert_not_hidden( card, msg='' )
    assert_equal [card.name], Card.search(:id=>card.id).map(&:name), msg
  end

  def assert_locked( card, msg='' )
    assert_equal false, card.ok?(:update), msg
  end

  def assert_not_locked( card, msg='' )
    assert_equal true, card.ok?(:update), msg
  end
end

include PermissionSpecHelper

describe Card::Set::All::Permissions do

  #FIXME - lots of good tests here, but generally disorganized.

  describe "reader rules" do
    before do
      @perm_card =  Card.new(:name=>'Home+*self+*read', :type=>'Pointer', :content=>'[[Anyone Signed In]]')
    end

    it "should be *all+*read by default" do
      card = Card.fetch('Home')
      card.read_rule_id.should == Card.fetch('*all+*read').id
      card.who_can(:read).should ==  [Card::AnyoneID]
      Account.as(:anonymous){ card.ok?(:read).should be_true }
    end

    it "should update to role ('Anyone Signed In')" do

      name = @perm_card.name
      Account.as_bot { @perm_card.save! }
      pc = Card[name]
      card = Card['Home']
      #warn "card #{name}, #{card.inspect}, #{pc.inspect}"
      pc.should be
      card.read_rule_id.should == pc.id
      card.who_can(:read).should == [Card::AuthID]
      Account.as(:anonymous){ card.ok?(:read).should be_false }
    end

    it "should update to user ('Joe Admin')" do
      @perm_card.content = '[[Joe Admin]]'
      Account.as_bot { @perm_card.save! }

      card = Card.fetch('Home')
      card.read_rule_id.should == @perm_card.id
      card.who_can(:read).should == [Card['joe_admin'].id]
      Account.as(:anonymous) { card.ok?(:read).should be_false }
      Account.as(:joe_user)  { card.ok?(:read).should be_false }
      Account.as(:joe_admin) { card.ok?(:read).should be_true  }
      Account.as_bot         { card.ok?(:read).should be_true  }
    end

    it "should revert to more general rule when more specific (self) rule is deleted" do
      Account.as_bot do
        @perm_card.save!
        @perm_card.delete!
      end
      card = Card.fetch('Home')
      card.read_rule_id.should == Card.fetch('*all+*read').id
    end

    it "should revert to more general rule when more specific (right) rule is deleted" do
      pc = nil
      Account.as_bot do
        pc=Card.create(:name=>'B+*right+*read', :type=>'Pointer', :content=>'[[Anyone Signed In]]')
      end
      pc.should be
      card = Card.fetch('A+B')
      card.read_rule_id.should == pc.id
      pc = Card.fetch(pc.name) #important to re-fetch to catch issues with detecting change in trash status.
      Account.as_bot { pc.delete }
      card = Card.fetch('A+B')
      card.read_rule_id.should == Card.fetch('*all+*read').id
    end

    it "should revert to more general rule when more specific rule is renamed" do

      Account.as_bot do
        @perm_card.save!
        @perm_card = Card[@perm_card.name]
        @perm_card.name = 'Something else+*self+*read'
        @perm_card.save!
      end

      card = Card.fetch('Home')
      card.read_rule_id.should == Card.fetch('*all+*read').id
    end

    it "should not be overruled by a more general rule added later" do
      Account.as_bot do
        @perm_card.save!
        c= Card.fetch('Home')
        c.type_id = Card::PhraseID
        c.save!
        Card.create(:name=>'Phrase+*type+*read', :type=>'Pointer', :content=>'[[Joe User]]')
      end

      card = Card.fetch('Home')
      card.read_rule_id.should == @perm_card.id
    end

    it "should get updated when trunk type change makes type-plus-right apply / unapply" do
      @perm_card.name = "Phrase+B+*type plus right+*read"
      Account.as_bot { @perm_card.save! }
      Card.fetch('A+B').read_rule_id.should == Card.fetch('*all+*read').id
      c = Card.fetch('A')
      c.type_id = Card::PhraseID
      c.save!
      Card.fetch('A+B').read_rule_id.should == @perm_card.id
    end

    it "should work with relative settings" do
      Account.as_bot do
        @perm_card.save!
        all_plus = Card.fetch '*all plus+*read', :new=>{:content=>'_left'}
        all_plus.save
      end
      c = Card.new(:name=>'Home+Heart')
      c.who_can(:read).should == [Card::AuthID]
      c.permission_rule_card(:read).first.id.should == @perm_card.id
      c.save
      c.read_rule_id.should == @perm_card.id
    end

    it "should get updated when relative settings change" do
      Account.as_bot do
        all_plus = Card.fetch '*all plus+*read', :new=>{:content=>'_left'}
        all_plus.save
      end
      c = Card.new(:name=>'Home+Heart')
      c.who_can(:read).should == [Card::AnyoneID]
      c.permission_rule_card(:read).first.id.should == Card.fetch('*all+*read').id
      c.save
      c.read_rule_id.should == Card.fetch('*all+*read').id
      Account.as_bot { @perm_card.save! }
      c2 = Card.fetch('Home+Heart')
      c2.who_can(:read).should == [Card::AuthID]
      c2.read_rule_id.should == @perm_card.id
      Card.fetch('Home+Heart').read_rule_id.should == @perm_card.id
      Account.as_bot{ @perm_card.delete }
      Card.fetch('Home').read_rule_id.should == Card.fetch('*all+*read').id
      Card.fetch('Home+Heart').read_rule_id.should == Card.fetch('*all+*read').id
    end

    it "should insure that class overrides work with relative settings" do
      Account.as_bot do
        all_plus = Card.fetch '*all plus+*read', :new => { :content=>'_left' }
        all_plus.save
        Account.as_bot { @perm_card.save! }
        c = Card.create(:name=>'Home+Heart')
        c.read_rule_id.should == @perm_card.id
        r = Card.create(:name=>'Heart+*right+*read', :type=>'Pointer', :content=>'[[Administrator]]')
        Card.fetch('Home+Heart').read_rule_id.should == r.id
      end
    end

    it "should work on virtual+virtual cards" do
      c = Card.fetch('Number+*type+by name')
      c.ok?(:read).should be_true
    end

  end



  context '??' do
    before do
      Account.as_bot do
  #      Account.cache.reset
        @u1, @u2, @u3, @r1, @r2, @r3, @c1, @c2, @c3 =
          %w( u1 u2 u3 r1 r2 r3 c1 c2 c3 ).map do |x| Card[x] end
      end
    end


    it "checking ok read should not add to errors" do
      Account.as_bot do
        Account.always_ok?.should == true
      end
      Account.as(:joe_user) do
        Account.always_ok?.should == false
      end
      Account.as(:joe_admin) do
        Account.always_ok?.should == true
        Card.create! :name=>"Hidden"
        Card.create(:name=>'Hidden+*self+*read', :type=>'Pointer', :content=>'[[Anyone Signed In]]')
      end

      Account.as(:anonymous) do
        h = Card.fetch('Hidden')
        h.ok?(:read).should == false
        h.errors.empty?.should_not == nil
      end
    end

    it "should be granted to admin if to anybody" do
      Account.as_bot do
        c1 = Card['c1']
        Card.create! :name=>'c1+*self+*comment', :type=>'Pointer', :content=>'[[r1]]'
        c1.who_can( :comment ).should == [Card['r1'].id]
        c1.ok?(:comment).should be_true
      end
    end

    it "reader setting" do
      Card.where(:trash=>false).each do |c|
        prc = c.permission_rule_card(:read)
        #warn "C #{c.inspect}, #{c.read_rule_id}, #{prc.first.id}, #{c.read_rule_class}, #{prc.second}, #{prc.first.inspect}" unless prc.last == c.read_rule_class && prc.first.id == c.read_rule_id
        prc.last.should == c.read_rule_class
        prc.first.id.should == c.read_rule_id
      end
    end


    it "write user permissions" do
      Account.as_bot do
        @u1.fetch(:trait=>:roles, :new=>{}).items = [@r1, @r2]
        @u2.fetch(:trait=>:roles, :new=>{}).items = [@r1, @r3]
        @u3.fetch(:trait=>:roles, :new=>{}).items = [@r1, @r2, @r3]

        cards=[1,2,3].map do |num|
          Card.create(:name=>"c#{num}+*self+*update", :type=>'Pointer', :content=>"[[u#{num}]]")
        end
      end

      @c1 = Card['c1']
      assert_not_locked_from( @u1, @c1 )
      assert_locked_from( @u2, @c1 )
      assert_locked_from( @u3, @c1 )

      @c2 = Card['c2']
      assert_locked_from( @u1, @c2 )
      assert_not_locked_from( @u2, @c2 )
      assert_locked_from( @u3, @c2 )
    end

    it "read group permissions" do
      Account.as_bot do
        @u1.fetch(:trait=>:roles).items = [@r1, @r2]
        @u2.fetch(:trait=>:roles).items = [@r1, @r3]

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
      Account.as_bot do
        [1,2,3].each do |num|
          Card.create(:name=>"c#{num}+*self+*update", :type=>'Pointer', :content=>"[[r#{num}]]")
        end

        @u3.fetch(:trait=>:roles, :new=>{}).items = [@r1]
      end

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
      Account.as_bot {
        @u1.fetch(:trait=>:roles, :new=>{}).items = [@r1, @r2]
        @u2.fetch(:trait=>:roles, :new=>{}).items = [@r1, @r3]
        @u3.fetch(:trait=>:roles, :new=>{}).items = [@r1, @r2, @r3]

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
       Account.as_bot do
         [@c1,@c2,@c3].each do |c|
           c.update_attributes :content => 'WeirdWord'
         end
         Card.create(:name=>"c1+*self+*read", :type=>'Pointer', :content=>"[[u1]]")
       end

       Account.as(@u1) do
         Card.search(:content=>'WeirdWord').map(&:name).sort.should == %w( c1 c2 c3 )
       end
       Account.as(@u2) do
         Card.search(:content=>'WeirdWord').map(&:name).sort.should == %w( c2 c3 )
       end
    end

    it "role wql" do
      #warn "u1 roles #{Card[ @u1.id ].fetch(:trait=>:roles).item_names.inspect}"

      # set up cards of type TestType, 2 with nil reader, 1 with role1 reader
      Account.as_bot do
        [@c1,@c2,@c3].each do |c|
          c.update_attributes :content => 'WeirdWord'
        end
        Card.create(:name=>"c1+*self+*read", :type=>'Pointer', :content=>"[[r3]]")
      end

      Account.as(@u1) do
        Card.search(:content=>'WeirdWord').map(&:name).sort.should == %w( c1 c2 c3 )
      end
      Account.current_id =nil # for Account.as to be effective, you can't have a logged in user
      Account.as(@u2) do
        Card.search(:content=>'WeirdWord').map(&:name).sort.should == %w( c2 c3 )
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




  it "should let joe view new cards" do
    Card.new.ok?(:read).should be_true
  end


  context "default permissions" do
    before do
      @c = Card.create! :name=>"sky blue"
    end

    it "should let anonymous users view basic cards" do
      Account.as :anonymous do
        @c.ok?(:read).should be_true
      end
    end

    it "should let joe user basic cards" do
      Account.as :joe_user do
        @c.ok?(:read).should be_true
      end
    end
  end

  it "should allow anyone signed in to create Basic Cards" do
    Card.new.ok?(:create).should be_true
  end

  it "should not allow someone not signed in to create Basic Cards" do
    Account.as :anonymous do
      Card.new.ok?(:create).should_not be_true
    end
  end



  context "settings based permissions" do
    before do
      Account.as_bot do
        @delete_rule_card = Card.fetch '*all+*delete', :new=>{}
        @delete_rule_card.type_id = Card::PointerID
        @delete_rule_card.content = '[[Joe_User]]'
        @delete_rule_card.save!
      end
    end

    it "should handle delete as a setting" do
      c = Card.new :name=>'whatever'
      c.who_can(:delete).should == [Card['joe_user'].id]
      Account.as(:joe_user) do
        c.ok?(:delete).should == true
      end
      Account.as(:u1) do
        c.ok?(:delete).should == false
      end
      Account.as(:anonymous) do
        c.ok?(:delete).should == false
      end
      Account.as_bot do
        c.ok?(:delete).should == true #because administrator
      end
    end
  end
end


# FIXME-perm

# need test for
# changing cardtypes gives you correct permissions (changing cardtype in general...)
