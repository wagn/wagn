require_relative 'test_helper'
require 'performance_test_help'

class CardCreateTest < ActionController::PerformanceTest
  # Replace this with your real tests.
  def initialize(*args)
    @name = 'CardA'
    super(*args)
    User.as(:wagbot)
  end

  def test_card_create_simple
    Card.create :name =>@name, :content=>"test content"
    @name = @name.next
  end               
  
  def test_card_create_links
    Card.create :name =>@name, :content=>"test [[CardA]]"
    @name = @name.next
  end
end
