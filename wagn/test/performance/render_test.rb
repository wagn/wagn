# -*- encoding : utf-8 -*-
require "test_helper"
require "rails/performance_test_help"

class RenderTest < ActionDispatch::PerformanceTest
  Card
  def render_test
    Card.new(name: "hi", content: "{{+plus1}} {{+plus2}} {{+plus3}}" .format).render :core
  end
end
