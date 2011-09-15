require_relative 'test_helper'
require 'performance_test_help'

class HomepageTest < ActionController::PerformanceTest
  # Replace this with your real tests.
  def test_homepage
    get '/Home'
    File.open("#{RAILS_ROOT}/log/response.html","w") do |f|
      f.puts response.body
    end
  end
end
