# -*- encoding : utf-8 -*-
require "test_helper"
require "rails/performance_test_help"

class FetchTest < ActionDispatch::PerformanceTest
  def test_fetch
    Card.fetch "Home"
  end
end
