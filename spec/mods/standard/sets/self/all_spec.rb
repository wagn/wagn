# -*- encoding : utf-8 -*-

describe Card::Set::Self::All do
  before do
    
    @all = Card[:all]
  end
  
  context '#update' do
    it 'should be trigger empty trash (with right params)' do
      Card::Auth.as_bot do
        Card['A'].delete!
        Card.where( :trash=>true ).should_not be_empty
        Card::Env.params[:task] = :empty_trash
        @all.update_attributes({})
        Card.where( :trash=>true ).should be_empty
      end
    end

    it 'should be trigger deleting old revisions (with right params)' do
      Card::Auth.as_bot do
        a = Card['A']
        a.update_attributes! :content=>'a new day'
        a.revisions.count.should == 2
        Card::Env.params[:task] = :delete_old_revisions
        @all.update_attributes({})
        a.revisions.count.should == 1        
      end
    end
    
  end
end
