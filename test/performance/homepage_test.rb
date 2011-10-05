require File.expand_path('test_helper', File.dirname(__FILE__))
require 'performance_test_help'

class HomepageTest < ActionController::PerformanceTest
  # Replace this with your real tests.
  def test_homepage
    get '/Home'
    File.open("#{Rails.root}/log/response.html","w") do |f|
      f.puts response.body
    end
  end
end
