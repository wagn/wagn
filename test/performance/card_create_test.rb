require File.expand_path('test_helper', File.dirname(__FILE__))
require 'performance_test_help'

class CardCreateTest < ActionController::PerformanceTest
  # Replace this with your real tests.
  def initialize(*args)
    @name = 'CardA'
    super(*args)
    #Account.as_bot { # this must have a block now }
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
