require File.dirname(__FILE__) + '/../../test_helper'
class Card::InvitationRequestTest < ActiveSupport::TestCase
  
  
  def setup
    setup_default_user  
    # make sure all this stuff works as anonymous user
    ::User.current_user = ::User.find_by_login('anon')
  end
  
 
  def test_should_require_name
    @card = Card::InvitationRequest.create :account=>{ :email=>"bunny@hop.com" }
    assert @card.errors.on(:name)
  end
  

  def test_should_require_unique_name
    @card = Card::InvitationRequest.create :name=>"Joe User", :account=>{ :email=>"jamaster@jay.net" }, :content=>"Let me in!"
    assert @card.errors.on(:name)
  end

     
  def test_should_block_user                      
    ::User.as(:wagbot)  do Role.find_by_codename('auth').update_attributes! :tasks=>'deny_invitation_requests' end
    ::User.as ::User.find_by_login('joe_user') do
      Card.find_by_name('Ron Request').destroy!
    end
    assert_equal nil, Card.find_by_name('Ron Request')
    assert_equal 'blocked', ::User.find_by_email('ron@request.com').status
  end

  
end
