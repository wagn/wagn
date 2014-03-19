# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card::Set::Right::Email do
  
  context '<User>+*email' do
    before do
      @card = Card.fetch 'u1+*email'
      @format = Card::Format.new @card, :format=>nil
    end

    it 'should allow Wagn Bot to read' do
      Card::Auth.as_bot do
        @format.render_raw.should == 'u1@user.com'
      end
    end

    it 'should allow self to read' do
      Card::Auth.as Card['u1'] do
        @format.render_raw.should == 'u1@user.com'
      end
    end

    it 'should hide from other users' do
      @card.ok?(:read).should be_false
      @format.render_raw.should =~ /denied/
    end
  end
  
  context "+*account+*email" do
    context 'update' do
      before :each do
        @email_card = email_card = Card['u1'].account.email_card
      end
      
      it 'should downcase email' do
        Card::Auth.as_bot do
          @email_card.update_attributes! :content=>'QuIrE@example.com'
          @email_card.content.should == 'quire@example.com'
        end
      end

      it 'should require valid email' do
        @email_card.update_attributes :content=>'boop'
        @email_card.errors[:content].first.should =~ /must be valid address/
      end
      
      it 'should require unique email' do
        @email_card.update_attributes :content=>'joe@user.com'
        @email_card.errors[:content].first.should =~ /must be unique/
      end
      
    end
  end

end
