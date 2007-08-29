require File.dirname(__FILE__) + '/../test_helper'
require 'cardtype_controller'

# Re-raise errors caught by the controller.
class CardtypeController; def rescue_action(e) raise e end; end

class CardtypeControllerTest < Test::Unit::TestCase
  def setup
    @controller = CardtypeController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
