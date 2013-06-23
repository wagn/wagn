# -*- encoding : utf-8 -*-
module Wagn::AuthenticatedTestHelper
  # Sets the current user in the session from the user fixtures.
  def login_as user
    Account.current_id = @request.session[:user] = (uc=Card[user.to_s] and uc.id)
    #warn "(ath)login_as #{user.inspect}, #{Account.current_id}, #{@request.session[:user]}"
  end

  def signout
    Account.current_id = @request.session[:user] = nil
  end


  # Assert the block redirects to the login
  #
  #   assert_requires_login(:bob) { get :edit, :id => 1 }
  #
  def assert_requires_login(user = nil, &block)
    login_as(user) if user
    block.call
    assert_redirected_to :controller => 'account', :action => 'login'
  end

  # Assert the block accepts the login
  #
  #   assert_accepts_login(:bob) { get :edit, :id => 1 }
  #
  # Accepts anonymous logins:
  #
  #   assert_accepts_login { get :list }
  #
  def assert_accepts_login(user = nil, &block)
    login_as(user) if user
    block.call
    assert_response :success
  end

  # http://project.ioni.st/post/217#post-217
  #
  #  def test_new_publication
  #    assert_difference(Publication, :count) do
  #      post :create, :publication => {...}
  #      # ...
  #    end
  #  end
  #


  def assert_new_account(&block)
    assert_difference(User, :count, 1) do
      assert_difference Card.where(:type_id=>Card::UserID), :count, 1, &block
    end
  end

  def assert_no_new_account(&block)
    assert_no_difference(User, :count) do
      assert_no_difference Card.where(:type_id=>Card::UserID), :count, &block
    end
  end

  def assert_status(email, status)
    u = Account[ email ]
    assert_equal status, u.status
  end
end
