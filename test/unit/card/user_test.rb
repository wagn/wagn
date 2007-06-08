require File.dirname(__FILE__) + '/../../test_helper'
class Card::UserTest < Test::Unit::TestCase
  common_fixtures
  def setup
    setup_default_user
  end
     
  def test_exists
  end 
 
=begin  
  def test_user_card_creation
    user = User.create(
      :email=>'test@blogzilla.org',
      :password=>'blothorsby', 
      :password_confirmation=>'blothorsby',
      :invited_by=>User.current_user
    )
    Card::User.create( :name=>"Blogfly" )
    assert_instance_of ::User, Card.find_by_name("Blogfly").extension
  end
=end  
  
end
