# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card::Set::All::Type do
  
  describe 'get_type_id (#new)' do
    it "should accept cardtype name and casespace variant as type" do
      Card.new( :type=>'Phrase'   ).type_id.should == Card::PhraseID
      Card.new( :type=>'PHRASE'   ).type_id.should == Card::PhraseID
      Card.new( :type=>'phrase'   ).type_id.should == Card::PhraseID
      Card.new( :type=>'phrase??' ).type_id.should == Card::PhraseID
    end
      
    it 'should accept type_code' do
      Card.new( :type_code=>'phrase'   ).type_id.should == Card::PhraseID
      Card.new( :type_code=>:phrase    ).type_id.should == Card::PhraseID
    end
    
    it 'should accept type_id' do
      Card.new( :type_id=>Card::PhraseID   ).type_code.should == :phrase
    end
  end
  
  describe 'card with wagneered type' do
    before do
      Account.as_bot do
        @type = Card.create! :name=>'Hat', :type=>'Cardtype'
      end
      @hat =  Card.new :type=>'Hat'
    end
    
    it 'should have a type_name' do
      @hat.type_name.should == 'Hat'
    end
    
    it 'should not have a type_code' do
      @hat.type_code.should == nil
    end
    
    it 'should have a type_id' do
      @hat.type_id.should == @type.id
    end
    
    it 'should have a type_card' do
      @hat.type_card.should == @type
    end

  end
end
