require File.dirname(__FILE__) + '/../../test_helper'
class Card::InvitationRequestTest < Test::Unit::TestCase
  common_fixtures
  
  def setup
    setup_default_user  
    # make sure all this stuff works as anonymous user
    ::User.current_user = ::User.find_by_login('anon')
  end
  
  def test_should_require_email
    @card = Card::InvitationRequest.create :name=>"James Boyle"
    assert @card.errors.on(:email)
  end

  def test_should_require_name
    @card = Card::InvitationRequest.create :email=>"bunny@hop.com"
    assert @card.errors.on(:name)
  end
  
  def test_should_require_unique_email
    @card = Card::InvitationRequest.create :name=>"Word Third", :email=>"joe@user.com", :content=>"Let me in!"
    assert @card.errors.on(:email)
  end

  def test_should_require_unique_name
    @card = Card::InvitationRequest.create :name=>"Joe User", :email=>"jamaster@jay.net", :content=>"Let me in!"
    assert @card.errors.on(:name)
  end

=begin # this is now going to be a configuration option
  def test_should_deny_destroy_permission
    ::User.as(:admin) do Role.find_by_codename('auth').update_attributes! :tasks=>'' end
    assert_raises Wagn::PermissionDenied do 
      ::User.as ::User.find_by_login('joe_user') do 
        Card.find_by_name('Ron Request').destroy!
      end
    end
  end
=end
            
  def test_should_block_user                      
    ::User.as(:admin) do Role.find_by_codename('auth').update_attributes! :tasks=>'deny_invitation_requests' end
    ::User.as ::User.find_by_login('joe_user') do
      Card.find_by_name('Ron Request').destroy!
    end
    assert_equal nil, Card.find_by_name('Ron Request')
    assert_equal 'blocked', ::User.find_by_email('ron@request.com').status
  end

  def test_should_now_allow_blocked_user                      
    ::User.as(:admin) do Card.find_by_name('Ron Request').destroy end
    @card = Card::InvitationRequest.create :name=>"Ron Re Request", :email=>'ron@request.com'
    assert @card.errors.on(:email)      
  end

  def test_should_create_card_and_user  
    Card::InvitationRequest.create :name=>"Word Third", :email=>"jamaster@jay.net", :content=>"Let me in!"
    @card =  Card.find_by_name("Word Third")   
    @user = @card.extension
    
    assert_instance_of Card::InvitationRequest, @card
    assert_instance_of ::User, @user
    assert_equal 'jamaster@jay.net', @user.email
    assert_equal 'request', @user.status
  end

  
end
