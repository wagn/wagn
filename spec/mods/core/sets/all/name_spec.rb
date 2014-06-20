# -*- encoding : utf-8 -*-

describe Card::Set::All::Name do
  describe 'autoname' do
    before do
      Card::Auth.as_bot do
        @b1 = Card.create! :name=>'Book+*type+*autoname', :content=>'b1'
      end
    end

    it "should handle cards without names" do
      c = Card.create! :type=>'Book'
      c.name.should== 'b1'
    end

    it "should increment again if name already exists" do
      b1 = Card.create! :type=>'Book'
      b2 = Card.create! :type=>'Book'
      b2.name.should== 'b2'
    end

    it "should handle trashed names" do
      b1 = Card.create! :type=>'Book'
      Card::Auth.as_bot { b1.delete }
      b1 = Card.create! :type=>'Book'
      b1.name.should== 'b1'
    end
  end
  
  describe 'codename' do
    before :each do
      @card = Card['a']
    end
    
    it 'should require admin permission' do
      @card.update_attributes :codename=>'structure'
      @card.errors[:codename].first.should =~ /only admins/
    end
    
    it 'should check uniqueness' do
      Card::Auth.as_bot do
        @card.update_attributes :codename=>'structure'
        @card.errors[:codename].first.should =~ /already in use/
      end
    end
    
  end
  
  describe 'repair_key' do
    it 'should fix broken keys' do
      a = Card['a']
      a.update_column 'key', 'broken_a'
      a.expire
      
      a = Card.find a.id
      a.key.should == 'broken_a'
      a.repair_key
      a.key.should == 'a'
    end
  end
end
