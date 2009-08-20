require 'test_helper'
require 'performance_test_help'

class HomepageTest < ActionController::PerformanceTest
  # Replace this with your real tests.
  def test_homepage
    get '/Home'
  end
end
