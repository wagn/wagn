# -*- encoding : utf-8 -*-
require "test_helper"
require "rails/performance_test_help"

class HomepageTest < ActionDispatch::PerformanceTest
  def test_homepage
    get "/"
  end
end
