# -*- encoding : utf-8 -*-

describe Card::Set::All::Type do
  
  describe 'get_type_id (#new)' do
    it "should accept cardtype name and casespace variant as type" do
      expect(Card.new( :type=>'Phrase'   ).type_id).to eq(Card::PhraseID)
      expect(Card.new( :type=>'PHRASE'   ).type_id).to eq(Card::PhraseID)
      expect(Card.new( :type=>'phrase'   ).type_id).to eq(Card::PhraseID)
      expect(Card.new( :type=>'phrase??' ).type_id).to eq(Card::PhraseID)
    end
      
    it 'should accept type_code' do
      expect(Card.new( :type_code=>'phrase'   ).type_id).to eq(Card::PhraseID)
      expect(Card.new( :type_code=>:phrase    ).type_id).to eq(Card::PhraseID)
    end
    
    it 'should accept type_id' do
      expect(Card.new( :type_id=>Card::PhraseID   ).type_code).to eq(:phrase)
    end
  end
  
  describe 'card with wagneered type' do
    before do
      Card::Auth.as_bot do
        @type = Card.create! :name=>'Hat', :type=>'Cardtype'
      end
      @hat =  Card.new :type=>'Hat'
    end
    
    it 'should have a type_name' do
      expect(@hat.type_name).to eq('Hat')
    end
    
    it 'should not have a type_code' do
      expect(@hat.type_code).to eq(nil)
    end
    
    it 'should have a type_id' do
      expect(@hat.type_id).to eq(@type.id)
    end
    
    it 'should have a type_card' do
      expect(@hat.type_card).to eq(@type)
    end

  end
  
  
  describe 'card with structured type' do
    before do
      Card::Auth.as_bot do
        Card.create! :name=>'Topic', :type=>'Cardtype'
        Card.create! :name=>'Topic+*type+*structure', :content=>'{{+results}}'
        Card.create! :name=>'Topic+results+*type plus right+*structure', :type=>'Search', :content=>'{}'
      end
    end
    
    it "should clear cache of structured included card after saving" do
      Card::Auth.as_bot do
        expect(Card.fetch('t1+results', :new=>{}).type_name).to eq('Basic')
        
        topic1 = Card.new :type=>'Topic', :name=>'t1'
        topic1.format._render_new
        topic1.save!
        expect(Card.fetch('t1+results', :new=>{}).type_name).to eq('Search')
      end
    end
  end
  
end
