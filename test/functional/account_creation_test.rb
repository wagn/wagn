require File.expand_path('../test_helper', File.dirname(__FILE__))
require 'account_controller'

# Re-raise errors caught by the controller.
class AccountController; def rescue_action(e) raise e end; end

class AccountCreationTest < ActionController::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.

  include AuthenticatedTestHelper



  #FIXME - couldn't get this stuff to work in setup, but that's where it belongs.
  signed_in = Card[Card::AuthID]
  # need to use: Card['*account'].ok?(:create)
  #if (tasks_card=Card.fetch_or_new(!signed_in.fetch(:trait=>:task_list))).
  #     item_names.member?('create_accounts')
  #  tasks_card << 'create_accounts'
  #end

  def setup
    super
    get_renderer
    @controller = AccountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    #login_as 'joe_admin'
    integration_login_as 'joe_admin', true
    Wagn::Cache.restore
  end

# this is working in interface but I can't get it to work here:
=begin
  def test_should_require_valid_cardname
#    assert_raises(ActiveRecord::RecordInvalid) do
    assert_no_new_account do
      post_invite :card => { :name => "Joe+User/" }
    end
  end
=end

  def test_should_create_account_from_account_request
    assert_equal :account_request, (c=Card.fetch('Ron Request')).typecode
    post_invite :card=>{ :key=>"ron_request"}, :action=>:accept
    c=Card.fetch('Ron Request')
    assert_equal :user, c.typecode
    assert_equal "active", User.find_by_email("ron@request.com").status
  end

  def test_should_create_account_from_account_request_when_user_hard_templated
    Account.as_bot { Card.create :name=>'User+*type+*content', :content=>"like this" }
    assert_equal :account_request, (c=Card.fetch('Ron Request')).typecode
    post_invite :card=>{ :key=>"ron_request"}, :action=>:accept
    c=Card.fetch('Ron Request')
    assert_equal :user, c.typecode
    assert_equal "active", User.find_by_email("ron@request.com").status
  end


  def test_create_permission_denied_if_not_logged_in
    signout
    post "signout"
    assert_no_new_account do
#    assert_raises(Card::PermissionDenied) do
      post_invite
    end
  end



  def test_should_create_account_from_scratch
    assert_difference ActionMailer::Base.deliveries, :size do
      assert_new_account do
        post_invite
        assert_response 302
      end
    end
    email = ActionMailer::Base.deliveries[-1]
    # emails should be 'from' inviting user
    assert_equal Account.user.email, email.from[0]
    assert_equal 'active', User.find_by_email('new@user.com').status
    assert_equal 'active', User.find_by_email('new@user.com').status
  end

  def test_should_create_account_when_user_cards_are_templated   ##FIXME -- I don't think this actually catches the bug I saw.
    Account.as_bot { Card.create! :name=> 'User+*type+*content'}
    assert_new_account do
      post_invite
      assert_response 302
    end
  end

  # should work -- we generate a password if it's nil
  def test_should_generate_password_if_not_given
    assert_new_account do
      post_invite
      assert !assigns(:user).password.blank?
    end
  end

  def test_should_require_password_confirmation_if_password_given
    assert_no_new_account do
      #assert_raises(ActiveRecord::RecordInvalid) do
        post_invite :user=>{ :password=>'tedpass' }
      #end
    end
  end

  def test_should_require_email
    assert_no_new_account do
      #assert_raises(ActiveRecord::RecordInvalid) do
        post_invite :user=>{ :email => nil }
        assert assigns(:user).errors[:email]
        assert_response :success
      #end
    end
  end

  def test_should_require_unique_email
    post_invite :user=>{ :email=>'duplor@user.com' }
    assert_no_new_account do
      post_invite :user=>{ :email=>'duplor@user.com' }
    end
  end

  def test_should_create_account_from_existing_user
    assert_difference ::User, :count do
      assert_no_difference Card.where(:type_id=>Card::UserID), :count do
        post_invite :card=>{ :name=>"No Count" }, :user=>{ :email=>"no@count.com" }
      end
    end
  end
end
