# -*- encoding : utf-8 -*-

describe Card::Subcards do

  describe 'creating card with subcards' do
    it 'works with subcard hash' do
      Card::Auth.as_bot do
        @card = Card.create! :name=>'card with subs', :subcards=> { '+sub1' => { :content => 'this is sub1'} }
      end
      expect(Card['card with subs+sub1'].content).to eq 'this is sub1'
    end

    it 'works with content string' do
      Card::Auth.as_bot do
        @card = Card.create! :name=>'card with subs', :subcards=> { '+sub1' => 'this is sub1'}
      end
      expect(Card['card with subs+sub1'].content).to eq 'this is sub1'
    end

    it 'works with +name key in args' do
      Card::Auth.as_bot do
        @card = Card.create! :name=>'card with subs', '+sub1' => { :content => 'this is sub1'}
      end
      expect(Card['card with subs+sub1'].content).to eq 'this is sub1'
    end

    it 'handles more than one level' do
      Card::Auth.as_bot do
        @card = Card.create! :name=>'card with subs', '+sub1' => { '+sub2' => 'this is sub2' }
      end
      expect(Card['card with subs+sub1+sub2'].content).to eq 'this is sub2'
    end

    it 'handles compound names' do
      Card::Auth.as_bot do
        @card = Card.create! :name=>'superman', '+*account+*email' => 'clark@sky.com'
      end
      expect(Card['superman+*account']).to be_truthy
      expect(Card['superman+*account+*email'].content).to eq 'clark@sky.com'
    end

    it 'keeps plural of left part' do
      Card::Auth.as_bot do
        @card = Card.create! :name=>'supermen', :content=>"something", :subcards=> {'+pseudonym' => 'clark'}
      end
      expect(Card['supermen+pseudonym'].name).to eq 'supermen+pseudonym'
    end

    it 'no stack level too deep' do
      Card::Auth.as_bot do
        @user_card = Card.create! :name=>'TmpUser', :type_id=>Card::UserID, '+*account'=>{
          '+*email'=>'tmpuser@wagn.org', '+*password'=>'tmp_pass'
        }
      end
    end

  end

  describe '#add_subfield' do
    before do
      @card = Card['A']
    end
    subject { Card.fetch("#{@card.name}+sub", :subcard=>true).content }
    it 'works with string' do
      @card.add_subfield 'sub', :content=>'this is a sub'
      is_expected.to eq 'this is a sub'
    end
    it 'works with codename' do
      @card.add_subfield :phrase, :content=>'this is a sub'
      expect(Card.fetch('A+phrase', :subcard=>true).content).to eq 'this is a sub'
    end
  end
  #
  # describe '#remove_subfield' do
  #
  # end

end