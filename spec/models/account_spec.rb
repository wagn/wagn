# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Account do

  it 'should authenticate user' do
    assert_equal Account[ 'joe@user.com' ].id, Account.authenticate('joe@user.com', 'joe_pass')
  end

  it 'should authenticate user despite whitespace' do
    assert_equal Account[ 'joe@user.com' ].id, Account.authenticate(' joe@user.com ', ' joe_pass ')
  end

  it 'should authenticate user with weird email capitalization' do
    assert Account.authenticate('JOE@user.com', 'joe_pass')
  end
  
end