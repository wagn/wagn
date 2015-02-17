# -*- encoding : utf-8 -*-

describe Card::Set::All::Initialize do
  describe "new" do
    it "handles explicit nil as parameters" do
      c = Card.new nil
      expect(c).to be_instance_of(Card)
      expect(c.name).to eq('')
    end

    it "handles nil name" do
      c = Card.new :name => nil
      expect(c).to be_instance_of(Card)
      expect(c.name).to eq('')
    end
    
    it 'handles legit name' do
      c = Card.new :name => 'Ceee'
      expect(c).to be_instance_of(Card)
      expect(c.name).to eq('Ceee')
    end    
  end
  
  
  describe "module inclusion" do
    context '(search)' do
      before do
        @c = Card.new :type=>'Search', :name=>'Module Inclusion Test Card'
      end

      it "happens after new" do
        expect(@c.respond_to?( :get_query )).to be_truthy
      end

      it "happens after save" do
        expect(@c.respond_to?( :get_query )).to be_truthy
        @c.save!
        expect(@c.respond_to?( :get_query )).to be_truthy
      end

      it "happens after fetch" do
        @c.save!
        c = Card.fetch(@c.name)
        expect(c.respond_to?( :get_query )).to be_truthy
      end
    end

    context '(pointer)' do
      it "happens with explicit pointer setting" do
        expect(Card.new(:type=>'Pointer').respond_to?(:add_item)).to be_truthy
      end

      it "happens with implicit pointer setting (from template)" do
        expect(Card.new(:name=>'Home+*cc').respond_to?(:add_item)).to be_truthy
      end
    end
  end
end
