# -*- encoding : utf-8 -*-

describe Card::Auth do
  it 'should authenticate user' do
    authenticated = Card::Auth.authenticate 'joe@user.com', 'joe_pass'
    assert_equal Card::Auth['joe@user.com'], authenticated
  end

  it 'should authenticate user despite whitespace' do
    authenticated = Card::Auth.authenticate ' joe@user.com ', ' joe_pass '
    assert_equal Card::Auth['joe@user.com'], authenticated
  end

  it 'should authenticate user with weird email capitalization' do
    assert Card::Auth.authenticate('JOE@user.com', 'joe_pass')
  end
end
