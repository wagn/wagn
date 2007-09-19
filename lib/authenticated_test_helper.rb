module AuthenticatedTestHelper
  # Sets the current user in the session from the user fixtures.
  def login_as(user)
    @request.session[:user] = User.find_by_login(user.to_s).id
    User.current_user = User.find(@request.session[:user])
  end
                 
  def logout
    @request.session[:user] = nil
    User.current_user = @request.session[:user]
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
      assert_difference Card, :count, 1, &block
    end
  end
  
  def assert_no_new_account(&block) 
    assert_no_difference(User, :count) do 
      assert_no_difference Card, :count, &block
    end
  end   
  
end