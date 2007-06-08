require File.dirname(__FILE__) + '/../test_helper'
require 'wagn_controller'

# Re-raise errors caught by the controller.
class WagnController; def rescue_action(e) raise e end; end

class WagnControllerTest < Test::Unit::TestCase
  def setup
    @controller = WagnController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
