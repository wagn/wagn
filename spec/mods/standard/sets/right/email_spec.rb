# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card::Set::Right::Email do
  
  before do
    @card = Card.fetch 'u1+*email'
    @format = Card::Format.new @card, :format=>nil
  end

  it 'should render email address' do
    Account.as_bot do
      @format.render_raw.should == 'u1@user.com'
    end
  end

  it 'should be visible to self' do
    Account.as Card['u1'] do
      @format.render_raw.should == 'u1@user.com'
    end
  end

  it 'should be hidden to other users' do
    @card.ok?(:read).should be_false
    @format.render_raw.should =~ /denied/
  end

=begin
  it "should render blank if +*email doesn't exist" do
    Account.as_bot do
      Card::Format.new( Card.fetch "A+*email" ).render_raw.should == ''
    end
  end
=end
  
  
  it 'should downcase email' do
    Account.as_bot do
      email_card = Card['u1'].account.email_card
      email_card.update_attributes! :content=>'QuIrE@example.com'
      email_card.content.should == 'quire@example.com'
    end
  end

end
