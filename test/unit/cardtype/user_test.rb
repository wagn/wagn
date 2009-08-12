=begin
require File.dirname(__FILE__) + '/../../test_helper'
class Card::UserTest < ActiveSupport::TestCase
  
  def setup
    setup_default_user
  end

  def test_should_create_user
    assert_difference Card::User, :count do
      assert_difference ::User, :count do
        Card::User.create :name=>"Johny C", :email=>"johny@c.com"
      end
    end
  end

  def test_should_create_card_without_user  
    assert_difference Card::User, :count do
      assert_no_difference ::User, :count do
        Card::User.create :name=>"Bill Clinton", :content=>"don't bother with account"
      end
    end
  end
  
  def test_should_require_unique_email
    @card = Card::User.create :name=>"Joe User II", :email=>'joe@user.com'
    assert @card.errors.on(:email)
  end
=end
  
 
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
  
end
=end  
