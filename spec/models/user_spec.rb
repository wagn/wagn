# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe User do
  
  describe 'update' do
    it 'should not rehash password' do
      Account[ 'joe@user.com' ].update_attributes!(:email => 'joe2@user.com')
      assert_equal Account[ 'joe2@user.com' ].card_id, Account.authenticate('joe2@user.com', 'joe_pass')
    end
  end
  
  describe "#read_rules" do
    before(:all) do
      @read_rules = Card['joe_user'].read_rules
    end


    it "*all+*read should apply to Joe User" do
      @read_rules.member?(Card.fetch('*all+*read').id).should be_true
    end

    it "3 more should apply to Joe Admin" do
      Account.as(:joe_admin) do
        ids = Account.as_card.read_rules
        #warn "rules = #{ids.map(&Card.method(:find)).map(&:name) * ', '}"
        ids.length.should == @read_rules.size + 4
      end
    end

  end
  
  
  it 'should reset password' do
    Account[ 'joe@user.com' ].update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal Account[ 'joe@user.com' ].card_id, Account.authenticate('joe@user.com', 'new password')
  end

  it 'should create user' do
    assert_difference User, :count do
      assert create_user.valid?
    end
  end

  it 'should require password' do
    assert_no_difference User, :count do
      u = create_user(:password => nil)
      assert u.errors[:password]
    end
  end

  it 'should require password confirmation' do
    assert_no_difference User, :count do
      u = create_user(:password_confirmation => nil)
      assert u.errors[:password_confirmation]
    end
  end

  it 'should require email' do
    assert_no_difference User, :count do
      u = create_user(:email => nil)
      assert u.errors[:email]
    end
  end

  it 'should downcase email' do
    u=create_user(:email=>'QuIrE@example.com')
    assert_equal 'quire@example.com', u.email
  end



#  def test_should_authenticate_user with same email as wagn bot
#    u1 = Account.admin
#  end

  protected
  
  def assert_difference(object, method = nil, difference = 1)
    initial_value = object.send(method)
    yield
    assert_equal initial_value + difference, object.send(method), "#{object}##{method}"
  end

  def assert_no_difference(object, method, &block)
    assert_difference object, method, 0, &block
  end
  
  def create_user(options = {})
    User.create({ :login => 'quire', :email => 'quire@example.com',
      :password => 'quire', :password_confirmation => 'quire',
      :card_id=>0, :account_id=>0
    }.merge(options))
  end
end
