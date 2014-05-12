require 'byebug'

shared_examples_for 'a supplier' do 
  subject(:supplier) do
    supplier = create_supplier_card
    # @factory = create_factory_card
    # @factory << supplier
    # @factory.putty
    supplier
  end
  let!(:factory) do
    f = create_factory_card 
    f << create_supplier_card
    f.putty
    f
  end
  
  context 'when removed' do
    it 'updates supplies card of related factory card' do
      #factory
      Card::Auth.as_bot do
        supplier.delete!
        #supplier.save!
      end
      f = Card.gimme "style with css+*style"
      f.supplies_card.item_cards.should == []
    end
    
    it 'updates file of related factory card' do
      factory
      Card::Auth.as_bot do
        supplier.delete!
        #esupplier.save!
      end
      f = Card.gimme factory.cardname
      path = f.product_card.attach.path
      expect(File.read path).to eq('')
    end
    
  end
  
  it 'delivers' do
    expect(supplier.deliver).to eq(card_content[:out])
  end
  
  
  context 'when updated' do
    it 'updates file of related factory card' do
      supplier.putty :content => card_content[:new_in]
      updated_factory  = Card.gimme factory.cardname
      path = updated_factory.product_card.attach.path
      expect(File.read path).to eq(card_content[:new_out])
    end
  end
  

end

