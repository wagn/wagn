require File.expand_path('../../test_helper', File.dirname(__FILE__))
class Wagn::Set::Type::AccountRequestTest < ActiveSupport::TestCase


  def setup
    super
    setup_default_user
    # make sure all this stuff works as anonymous user
    Account.user = Card::AnonID
  end


  def test_should_require_name
    @card = Card.create  :type_id=>Card::AccountRequestID #, :account=>{ :email=>"bunny@hop.com" } currently no api for this
    #Rails.logger.info "name errors: #{@card.errors.full_messages.inspect}"
    assert @card.errors[:name]
  end


  def test_should_require_unique_name
    @card = Card.create :typecode=>'account_request', :name=>"Joe User", :content=>"Let me in!"# :account=>{ :email=>"jamaster@jay.net" }
    assert @card.errors[:name]
  end


  def test_should_block_user
    c=Card.fetch('Ron Request')
    Account.as 'joe_admin' do c.destroy!  end
    warn "destroyed card (#{c.inspect}) #{User.where(:email=>'ron@request.com').first.inspect}"

    assert_equal nil, Card.fetch('Ron Request')
    assert_equal 'blocked', User.where(:email=>'ron@request.com').first.status
  end


end
