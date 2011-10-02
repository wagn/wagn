require_relative '../../test_helper'
class Wagn::Set::Type::InvitationRequestTest < ActiveSupport::TestCase
  
  
  def setup
    super
    setup_default_user  
    # make sure all this stuff works as anonymous user
    ::User.current_user = ::User.find_by_login('anon')
  end
  
 
  def test_should_require_name
    @card = Card.create  :typecode=>'InvitationRequest' #, :account=>{ :email=>"bunny@hop.com" } currently no api for this
    #Rails.logger.info "name errors: #{@card.errors.full_messages.inspect}"
    assert @card.errors.on(:name)
  end
  

  def test_should_require_unique_name
    @card = Card.create :typecode=>'InvitationRequest', :name=>"Joe User", :content=>"Let me in!"# :account=>{ :email=>"jamaster@jay.net" }
    assert @card.errors.on(:name)
  end

     
  def test_should_block_user                      
    ::User.as(:wagbot)  do Role.find_by_codename('auth').update_attributes! :tasks=>'deny_invitation_requests' end
    ::User.as ::User.find_by_login('joe_user') do
      Card.fetch('Ron Request').destroy!
    end
    assert_equal nil, Card.fetch('Ron Request')
    assert_equal 'blocked', ::User.find_by_email('ron@request.com').status
  end

  
end
