require File.expand_path('../../test_helper', File.dirname(__FILE__))
class Card::CreateTest < ActiveSupport::TestCase
  
  def setup
    super
    setup_default_user
  end
  def test_fetch_or_create_when_present
    Card.create!(:name=>"Carrots")
    assert_no_difference Card, :count do 
      assert_instance_of Card, Card.fetch_or_create("Carrots")
    end
  end  
  
  def test_simple
    assert_difference Card, :count do 
      assert_instance_of Card, Card.create(:name=>"Boo!")
      assert Card["Boo!"]
    end
  end
  
  
  def test_fetch_or_create_when_not_present
    Rails.logger.info "testing point 0"
    assert_difference Card, :count do 
    Rails.logger.info "testing point 1"
      assert_instance_of Card, c=Card.fetch_or_create("Tomatoes")
      Rails.logger.info "testing point 2 #{c}, #{c.cardname.inspect}"
    end
  end
  
  def test_create_junction
    Rails.logger.info "testing point a"
    assert_difference Card, :count, 3 do
    Rails.logger.info "testing point b"
      assert_instance_of Card, c=Card.create(:name=>"Peach+Pear", :content=>"juicy")
    Rails.logger.info "testing point c #{c}, #{c.cardname.inspect}"
    end
    assert_instance_of Card, Card["Peach"]
    assert_instance_of Card, Card["Pear"]
    assert_equal "juicy", Card["Peach+Pear"].content
  end
end

