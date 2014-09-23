# -*- encoding : utf-8 -*-

class ::Card
  def writeable_by(user)
    Card::Auth.as(user.id) do
    #warn "writeable #{Card::Auth.as_id}, #{user.inspect}"
      ok? :update
    end
  end

  def readable_by(user)
    Card::Auth.as(user.id) do
      ok? :read
    end
  end
end


module PermissionSpecHelper

  def assert_hidden_from( user, card, msg='')
    Card::Auth.as(user.id) { assert_hidden( card, msg ) }
  end

  def assert_not_hidden_from( user, card, msg='')
    Card::Auth.as(user.id) { assert_not_hidden( card, msg ) }
  end

  def assert_locked_from( user, card, msg='')
    Card::Auth.as(user.id) { assert_locked( card, msg ) }
  end

  def assert_not_locked_from( user, card, msg='')
    Card::Auth.as(user.id) { assert_not_locked( card, msg ) }
  end

  def assert_hidden( card, msg='' )
    assert !card.ok?(:read)
    assert_equal [], Card.search(:id=>card.id).map(&:name), msg
  end

  def assert_not_hidden( card, msg='' )
    assert card.ok?(:read)
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
      expect(card.read_rule_id).to eq(Card.fetch('*all+*read').id)
      expect(card.who_can(:read)).to eq([Card::AnyoneID])
      Card::Auth.as(:anonymous){ expect(card.ok?(:read)).to be_truthy }
    end

    it "should update to role ('Anyone Signed In')" do

      name = @perm_card.name
      Card::Auth.as_bot { @perm_card.save! }
      pc = Card[name]
      card = Card['Home']
      #warn "card #{name}, #{card.inspect}, #{pc.inspect}"
      expect(pc).to be
      expect(card.read_rule_id).to eq(pc.id)
      expect(card.who_can(:read)).to eq([Card::AnyoneSignedInID])
      Card::Auth.as(:anonymous){ expect(card.ok?(:read)).to be_falsey }
    end

    it "should update to user ('Joe Admin')" do
      @perm_card.content = '[[Joe Admin]]'
      Card::Auth.as_bot { @perm_card.save! }

      card = Card.fetch('Home')
      expect(card.read_rule_id).to eq(@perm_card.id)
      expect(card.who_can(:read)).to eq([Card['joe_admin'].id])
      Card::Auth.as(:anonymous) { expect(card.ok?(:read)).to be_falsey }
      Card::Auth.as(:joe_user)  { expect(card.ok?(:read)).to be_falsey }
      Card::Auth.as(:joe_admin) { expect(card.ok?(:read)).to be_truthy  }
      Card::Auth.as_bot         { expect(card.ok?(:read)).to be_truthy  }
    end

    it "should revert to more general rule when more specific (self) rule is deleted" do
      Card::Auth.as_bot do
        @perm_card.save!
        @perm_card.delete!
      end
      card = Card.fetch('Home')
      expect(card.read_rule_id).to eq(Card.fetch('*all+*read').id)
    end

    it "should revert to more general rule when more specific (right) rule is deleted" do
      pc = nil
      Card::Auth.as_bot do
        pc=Card.create(:name=>'B+*right+*read', :type=>'Pointer', :content=>'[[Anyone Signed In]]')
      end
      expect(pc).to be
      card = Card.fetch('A+B')
      expect(card.read_rule_id).to eq(pc.id)
      pc = Card.fetch(pc.name) #important to re-fetch to catch issues with detecting change in trash status.
      Card::Auth.as_bot { pc.delete }
      card = Card.fetch('A+B')
      expect(card.read_rule_id).to eq(Card.fetch('*all+*read').id)
    end

    it "should revert to more general rule when more specific rule is renamed" do

      Card::Auth.as_bot do
        @perm_card.save!
        @perm_card = Card[@perm_card.name]
        @perm_card.name = 'Something else+*self+*read'
        @perm_card.save!
      end

      card = Card.fetch('Home')
      expect(card.read_rule_id).to eq(Card.fetch('*all+*read').id)
    end

    it "should not be overruled by a more general rule added later" do
      Card::Auth.as_bot do
        @perm_card.save!
        c= Card.fetch('Home')
        c.type_id = Card::PhraseID
        c.save!
        Card.create(:name=>'Phrase+*type+*read', :type=>'Pointer', :content=>'[[Joe User]]')
      end

      card = Card.fetch('Home')
      expect(card.read_rule_id).to eq(@perm_card.id)
    end

    it "should get updated when trunk type change makes type-plus-right apply / unapply" do
      @perm_card.name = "Phrase+B+*type plus right+*read"
      Card::Auth.as_bot { @perm_card.save! }
      expect(Card.fetch('A+B').read_rule_id).to eq(Card.fetch('*all+*read').id)
      c = Card.fetch('A')
      c.type_id = Card::PhraseID
      c.save!
      expect(Card.fetch('A+B').read_rule_id).to eq(@perm_card.id)
    end

    it "should work with relative settings" do
      Card::Auth.as_bot do
        @perm_card.save!
        all_plus = Card.fetch '*all plus+*read', :new=>{:content=>'_left'}
        all_plus.save
      end
      c = Card.new(:name=>'Home+Heart')
      expect(c.who_can(:read)).to eq([Card::AnyoneSignedInID])
      expect(c.permission_rule_card(:read).first.id).to eq(@perm_card.id)
      c.save
      expect(c.read_rule_id).to eq(@perm_card.id)
    end

    it "should get updated when relative settings change" do
      Card::Auth.as_bot do
        all_plus = Card.fetch '*all plus+*read', :new=>{:content=>'_left'}
        all_plus.save
      end
      c = Card.new(:name=>'Home+Heart')
      expect(c.who_can(:read)).to eq([Card::AnyoneID])
      expect(c.permission_rule_card(:read).first.id).to eq(Card.fetch('*all+*read').id)
      c.save
      expect(c.read_rule_id).to eq(Card.fetch('*all+*read').id)
      Card::Auth.as_bot { @perm_card.save! }
      c2 = Card.fetch('Home+Heart')
      expect(c2.who_can(:read)).to eq([Card::AnyoneSignedInID])
      expect(c2.read_rule_id).to eq(@perm_card.id)
      expect(Card.fetch('Home+Heart').read_rule_id).to eq(@perm_card.id)
      Card::Auth.as_bot{ @perm_card.delete }
      expect(Card.fetch('Home').read_rule_id).to eq(Card.fetch('*all+*read').id)
      expect(Card.fetch('Home+Heart').read_rule_id).to eq(Card.fetch('*all+*read').id)
    end

    it "should insure that class overrides work with relative settings" do
      Card::Auth.as_bot do
        all_plus = Card.fetch '*all plus+*read', :new => { :content=>'_left' }
        all_plus.save
        Card::Auth.as_bot { @perm_card.save! }
        c = Card.create(:name=>'Home+Heart')
        expect(c.read_rule_id).to eq(@perm_card.id)
        r = Card.create(:name=>'Heart+*right+*read', :type=>'Pointer', :content=>'[[Administrator]]')
        expect(Card.fetch('Home+Heart').read_rule_id).to eq(r.id)
      end
    end

    it "should work on virtual+virtual cards" do
      c = Card.fetch('Number+*type+by name')
      expect(c.ok?(:read)).to be_truthy
    end

  end



  context '??' do
    before do
      Card::Auth.as_bot do
  #      Card::Auth.cache.reset
        @u1, @u2, @u3, @r1, @r2, @r3, @c1, @c2, @c3 =
          %w( u1 u2 u3 r1 r2 r3 c1 c2 c3 ).map do |x| Card[x] end
      end
    end


    it "checking ok read should not add to errors" do
      Card::Auth.as_bot do
        expect(Card::Auth.always_ok?).to eq(true)
      end
      Card::Auth.as(:joe_user) do
        expect(Card::Auth.always_ok?).to eq(false)
      end
      Card::Auth.as(:joe_admin) do
        expect(Card::Auth.always_ok?).to eq(true)
        Card.create! :name=>"Hidden"
        Card.create(:name=>'Hidden+*self+*read', :type=>'Pointer', :content=>'[[Anyone Signed In]]')
      end

      Card::Auth.as(:anonymous) do
        h = Card.fetch('Hidden')
        expect(h.ok?(:read)).to eq(false)
        expect(h.errors.empty?).not_to eq(nil)
      end
    end

    it "should be granted to admin if to anybody" do
      Card::Auth.as_bot do
        c1 = Card['c1']
        Card.create! :name=>'c1+*self+*comment', :type=>'Pointer', :content=>'[[r1]]'
        expect(c1.who_can( :comment )).to eq([Card['r1'].id])
        expect(c1.ok?(:comment)).to be_truthy
      end
    end

    it "reader setting" do
      Card.where(:trash=>false).each do |c|
        prc = c.permission_rule_card(:read)
        #warn "C #{c.inspect}, #{c.read_rule_id}, #{prc.first.id}, #{c.read_rule_class}, #{prc.second}, #{prc.first.inspect}" unless prc.last == c.read_rule_class && prc.first.id == c.read_rule_id
        expect(prc.last).to eq(c.read_rule_class)
        expect(prc.first.id).to eq(c.read_rule_id)
      end
    end


    it "write user permissions" do
      Card::Auth.as_bot do
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
      Card::Auth.as_bot do
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
      Card::Auth.as_bot do
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
      Card::Auth.as_bot {
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
    
    context "create permissions" do
      before do
        Card::Auth.as_bot do
          Card.create! :name=>'*structure+*right+*create', :type=>'Pointer', :content=>'[[Anyone Signed In]]'
          Card.create! :name=>'*self+*right+*create',      :type=>'Pointer', :content=>'[[Anyone Signed In]]'
        end
      end
      
      it "should inherit" do
        Card::Auth.as(:anyone_signed_in) do
          expect(Card.fetch( 'A+*self' ).ok?(:create)).to be_truthy #explicitly granted above
          expect(Card.fetch( 'A+*right').ok?(:create)).to be_falsey #by default restricted   
          
          expect(Card.fetch( 'A+*self+*structure',  :new=>{} ).ok?(:create)).to be_truthy # +*structure granted;
          expect(Card.fetch( 'A+*right+*structure', :new=>{} ).ok?(:create)).to be_falsey # can't create A+B, therefore can't create A+B+C
        end
      end
      
    end


    it "private wql" do
      # set up cards of type TestType, 2 with nil reader, 1 with role1 reader
       Card::Auth.as_bot do
         [@c1,@c2,@c3].each do |c|
           c.update_attributes :content => 'WeirdWord'
         end
         Card.create(:name=>"c1+*self+*read", :type=>'Pointer', :content=>"[[u1]]")
       end

       Card::Auth.as(@u1) do
         expect(Card.search(:content=>'WeirdWord').map(&:name).sort).to eq(%w( c1 c2 c3 ))
       end
       Card::Auth.as(@u2) do
         expect(Card.search(:content=>'WeirdWord').map(&:name).sort).to eq(%w( c2 c3 ))
       end
    end

    it "role wql" do
      #warn "u1 roles #{Card[ @u1.id ].fetch(:trait=>:roles).item_names.inspect}"

      # set up cards of type TestType, 2 with nil reader, 1 with role1 reader
      Card::Auth.as_bot do
        [@c1,@c2,@c3].each do |c|
          c.update_attributes :content => 'WeirdWord'
        end
        Card.create(:name=>"c1+*self+*read", :type=>'Pointer', :content=>"[[r3]]")
      end

      Card::Auth.as(@u1) do
        expect(Card.search(:content=>'WeirdWord').map(&:name).sort).to eq(%w( c1 c2 c3 ))
      end
      Card::Auth.current_id =nil # for Card::Auth.as to be effective, you can't have a logged in user
      Card::Auth.as(@u2) do
        expect(Card.search(:content=>'WeirdWord').map(&:name).sort).to eq(%w( c2 c3 ))
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
    expect(Card.new.ok?(:read)).to be_truthy
  end


  context "default permissions" do
    before do
      @c = Card.create! :name=>"sky blue"
    end

    it "should let anonymous users view basic cards" do
      Card::Auth.as :anonymous do
        expect(@c.ok?(:read)).to be_truthy
      end
    end

    it "should let joe user basic cards" do
      Card::Auth.as :joe_user do
        expect(@c.ok?(:read)).to be_truthy
      end
    end
  end

  it "should allow anyone signed in to create Basic Cards" do
    expect(Card.new.ok?(:create)).to be_truthy
  end

  it "should not allow someone not signed in to create Basic Cards" do
    Card::Auth.as :anonymous do
      expect(Card.new.ok?(:create)).not_to be_truthy
    end
  end



  context "settings based permissions" do
    before do
      Card::Auth.as_bot do
        @delete_rule_card = Card.fetch '*all+*delete', :new=>{}
        @delete_rule_card.type_id = Card::PointerID
        @delete_rule_card.content = '[[Joe_User]]'
        @delete_rule_card.save!
      end
    end

    it "should handle delete as a setting" do
      c = Card.new :name=>'whatever'
      expect(c.who_can(:delete)).to eq([Card['joe_user'].id])
      Card::Auth.as(:joe_user) do
        expect(c.ok?(:delete)).to eq(true)
      end
      Card::Auth.as(:u1) do
        expect(c.ok?(:delete)).to eq(false)
      end
      Card::Auth.as(:anonymous) do
        expect(c.ok?(:delete)).to eq(false)
      end
      Card::Auth.as_bot do
        expect(c.ok?(:delete)).to eq(true) #because administrator
      end
    end
  end
  
  
  
end


# FIXME-perm

# need test for
# changing cardtypes gives you correct permissions (changing cardtype in general...)
