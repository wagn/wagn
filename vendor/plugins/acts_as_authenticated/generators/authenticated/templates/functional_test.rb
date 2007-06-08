require File.dirname(__FILE__) + '/../test_helper'
require '<%= controller_file_name %>_controller'

# Re-raise errors caught by the controller.
class <%= controller_class_name %>Controller; def rescue_action(e) raise e end; end

class <%= controller_class_name %>ControllerTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
  include AuthenticatedTestHelper

  fixtures :<%= table_name %>

  def setup
    @controller = <%= controller_class_name %>Controller.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_login_and_redirect
    post :login, :login => 'quentin', :password => 'quentin'
    assert session[:<%= file_name %>]
    assert_response :redirect
  end

  def test_should_fail_login_and_not_redirect
    post :login, :login => 'quentin', :password => 'bad password'
    assert_nil session[:<%= file_name %>]
    assert_response :success
  end

  def test_should_allow_signup
    assert_difference <%= class_name %>, :count do
      create_<%= file_name %>
      assert_response :redirect
    end
  end

  def test_should_require_login_on_signup
    assert_no_difference <%= class_name %>, :count do
      create_<%= file_name %>(:login => nil)
      assert assigns(:<%= file_name %>).errors.on(:login)
      assert_response :success
    end
  end

  def test_should_require_password_on_signup
    assert_no_difference <%= class_name %>, :count do
      create_<%= file_name %>(:password => nil)
      assert assigns(:<%= file_name %>).errors.on(:password)
      assert_response :success
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference <%= class_name %>, :count do
      create_<%= file_name %>(:password_confirmation => nil)
      assert assigns(:<%= file_name %>).errors.on(:password_confirmation)
      assert_response :success
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference <%= class_name %>, :count do
      create_<%= file_name %>(:email => nil)
      assert assigns(:<%= file_name %>).errors.on(:email)
      assert_response :success
    end
  end

  def test_should_logout
    login_as :quentin
    get :logout
    assert_nil session[:<%= file_name %>]
    assert_response :redirect
  end

  protected
  def create_<%= file_name %>(options = {})
    post :signup, :<%= file_name %> => { :login => 'quire', :email => 'quire@example.com', 
                             :password => 'quire', :password_confirmation => 'quire' }.merge(options)
  end
end
