require File.dirname(__FILE__) + '/../test_helper'
require 'block_controller'

# Re-raise errors caught by the controller.
class BlockController; def rescue_action(e) raise e end; end

class BlockControllerTest < Test::Unit::TestCase
  common_fixtures
  
  def setup
    @controller = BlockController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @user = User.find(:first)
    @id = Card.find_by_name('Admin').id
  end

=begin  
  def test_connections
    get :card_list, {:id=>@id, :query=>'connections' }, { :user=>@user.id }
    assert_response :success
    assert_equal assigns['cards'], Card.find_by_wql("cards related to cards with id=#{@id} order by name")
  end
  

  def test_connections_with_transcludes
    Card.find_by_name('Admin').content="{{#{JOINT}Oak}}"
    get :card_list, {:id=>@id, :query=>'connections' }, { :user=>@user.id }
    assert_response :success
    assert_equal (Card.find_by_wql("cards related to cards with id=#{@id} order by name") - [Card.find_by_name("Admin#{JOINT}Oak")]).plot(:name), assigns['cards'].plot(:name)
  end
=end


end
