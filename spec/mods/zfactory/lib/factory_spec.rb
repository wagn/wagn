require 'byebug'

alias :old_method_missing :method_missing
def that_produces type
  type
end

def method_missing m, *args, &block
  case m
  when /that_produces_(.+)/
    return $1
  else
    old_method_missing m, args, block
  end
end


shared_examples_for 'a factory' do |filetype|
  context "when created" do
    it 'has a supplies card' do
      factory.supplies_card.should_not be_nil
    end
    it 'has a product card' do
      factory.product_card.should_not be_nil
    end
    it "generates #{filetype} file" do
      path = factory.product_card.attach.path
      path.should match "\.#{filetype}$"
    end
  end
end

shared_examples_for 'a content card factory' do |filetype|
  it_should_behave_like 'a factory', that_produces(filetype) do
    let(:factory) { factory_card }
  end
  
  context 'supplies card' do
    it "points to self" do
      factory_card.supplies_card.item_cards.should == [factory_card]
    end
  end
  
  context 'product card' do
    it 'creates file with supplied content' do
      path = factory_card.product_card.attach.path
      expect(File.read(path)).to eq(card_content[:out])
    end
    it "updates #{filetype} file when content is changed" do
      changed_factory = factory_card
      changed_factory.putty :content =>card_content[:new_in]
      changed_path = changed_factory.product_card.attach.path
      expect(File.read(changed_path)).to eq(card_content[:new_out])
    end
  end
end


shared_examples_for 'a pointer card factory' do |filetype|
  subject do
    change_factory = factory_card
    @depth = 4
    @expected_items = []
    Card::Auth.as_bot do
      (2*@depth).times do |i|
        @expected_items << Card.fetch( "basic level #{i}", :new =>  {:type => Card::BasicID } )
        @expected_items.last.save
      end
      last_level = false
      @depth.times do |i|
        next_level = Card.fetch(  "#{filetype} level #{@depth-i}", :new => {:type => :pointer } )
        next_level.content = ""
        next_level << @expected_items[@depth-i-1]
        next_level << last_level if last_level
        next_level << @expected_items[@depth+i]
        next_level.save!
        last_level = next_level
      end
      change_factory << last_level
      change_factory << supplier_card
      @expected_items << supplier_card
      change_factory.save!
    end
    change_factory
  end

  it_should_behave_like 'a factory', that_produces(filetype) do
    let(:factory) { factory_card }
  end
  
  describe 'supplies card' do
    it "contains items of all levels" do
      subject.supplies_card.item_cards.map(&:id).sort.should == @expected_items.map(&:id).sort
    end
    
    it "preserves order of items" do
      subject.supplies_card.item_cards.map(&:id).should == @expected_items.map(&:id)
    end
  end
  
  describe 'product card' do
    it 'creates #{filetype} file with supplied content' do
      path = subject.product_card.attach.path
      expect(File.read(path)).to eq(card_content[:out])
    end
    
    it 'updates #{filetype} file if item is changed' do
      supplier_card.putty :content => card_content[:new_in]
      changed_path = subject.product_card.attach.path
      expect(File.read(changed_path)).to eq(card_content[:new_out])
    end
  end
end
