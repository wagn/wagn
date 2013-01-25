require 'test_helper'
require 'rails/performance_test_help'
 
class CardCreateTest < ActionDispatch::PerformanceTest
  # Replace this with your real tests.
  def initialize(*args)
    @name = 'CardA'
    super(*args)
    Account.as Card::WagnBotID
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
