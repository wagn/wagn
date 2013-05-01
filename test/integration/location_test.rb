# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))

require 'card_controller'

class CardController
  def rescue_action(e) raise e end
end


class LocationTest < ActionController::IntegrationTest

  include LocationHelper

  def setup
    super
    setup_default_user
    integration_login_as 'joe_user'
  end

  def test_previous_location_should_be_assigned_after_viewing
    get "Joe_User"
    assert_equal "/Joe_User", assigns['previous_location']
  end

  def test_previous_location_should_not_be_updated_by_nonexistent_card
    get "Joe_User"
    get "Not_Me"
    get '*previous'
    assert_redirected_to '/Joe_User'
  end

  def test_return_to_special_url_when_logging_in_after_visit
    get '/recent'
    assert_equal "/*recent",  assigns['previous_location']
  end
end
