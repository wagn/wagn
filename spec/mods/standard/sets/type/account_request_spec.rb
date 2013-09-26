# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card::Set::Type::AccountRequest do
  
  before do
    Account.current_id = Card::AnonID
  end
  
  context 'valid request' do
    before do
      card = Card.create! :name=>'Big Bad Wolf', :type=>'Account Request', :account_args=>{:email=>'dude@wagn.org'}
      @format = Card::Format.new card
    end

    it "should not show invite links to anonymous users" do
      @format.render_core.should_not =~ /invitation-link/
    end
    
    it 'should show invite links to those who can invite' do
      Account.as_bot do
        assert_view_select @format.render(:core), 'a[class="invitation-link"]'
      end
    end
  end

  it 'should require name' do
    card = Card.create :type_id=>Card::AccountRequestID #, :account=>{ :email=>"bunny@hop.com" } currently no api for this
    #Rails.logger.info "name errors: #{@card.errors.full_messages.inspect}"
    assert card.errors[:name]
  end


 it 'should require a unique name' do
    @card = Card.create :type_code=>'account_request', :name=>"Joe User", :content=>"Let me in!"# :account=>{ :email=>"jamaster@jay.net" }
    assert @card.errors[:name]
  end


  it 'should block user upon delete' do
    Account.as_bot do
      Card.fetch('Ron Request').delete!
    end

    assert_equal nil, Card.fetch('Ron Request')
    assert_equal 'blocked', Account['ron@request.com'].status
  end
end
