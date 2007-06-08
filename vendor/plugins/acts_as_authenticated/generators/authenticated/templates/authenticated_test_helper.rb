module AuthenticatedTestHelper
  # Sets the current <%= file_name %> in the session from the <%= file_name %> fixtures.
  def login_as(<%= file_name %>)
    @request.session[:<%= file_name %>] = <%= table_name %>(<%= file_name %>).id
  end

  # Assert the block redirects to the login
  # 
  #   assert_requires_login(:bob) { get :edit, :id => 1 }
  #
  def assert_requires_login(<%= file_name %> = nil, &block)
    login_as(<%= file_name %>) if <%= file_name %>
    block.call
    assert_redirected_to :controller => '<%= controller_file_name %>', :action => 'login'
  end

  # Assert the block accepts the login
  # 
  #   assert_accepts_login(:bob) { get :edit, :id => 1 }
  #
  # Accepts anonymous logins:
  #
  #   assert_accepts_login { get :list }
  #
  def assert_accepts_login(<%= file_name %> = nil, &block)
    login_as(<%= file_name %>) if <%= file_name %>
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
  def assert_difference(object, method = nil, difference = 1)
    initial_value = object.send(method)
    yield
    assert_equal initial_value + difference, object.send(method), "#{object}##{method}"
  end

  def assert_no_difference(object, method, &block)
    assert_difference object, method, 0, &block
  end
end