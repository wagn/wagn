require File.dirname(__FILE__) + '/../test_helper'
require 'cardname_controller'

# Re-raise errors caught by the controller.
class CardnameController; def rescue_action(e) raise e end; end

class CardnameControllerTest < Test::Unit::TestCase
  def setup
    @controller = CardnameController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
