# -*- encoding : utf-8 -*-

describe Card::Auth do

  it 'should authenticate user' do
    assert_equal Card::Auth[ 'joe@user.com' ].id, Card::Auth.authenticate('joe@user.com', 'joe_pass')
  end

  it 'should authenticate user despite whitespace' do
    assert_equal Card::Auth[ 'joe@user.com' ].id, Card::Auth.authenticate(' joe@user.com ', ' joe_pass ')
  end

  it 'should authenticate user with weird email capitalization' do
    assert Card::Auth.authenticate('JOE@user.com', 'joe_pass')
  end
  
end