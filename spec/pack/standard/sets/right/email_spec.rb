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

  it 'should be hidden to Joe User by default' do
    @card.ok?(:read).should be_false
    @format.render_raw.should =~ /denied/
  end

  it "should render blank if email doesn't exist" do
    Account.as_bot do
      Card::Format.new( Card.fetch "A+*email" ).render_raw.should == ''
    end
  end
end
