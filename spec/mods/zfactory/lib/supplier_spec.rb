require 'byebug'

shared_examples_for 'a supplier' do 
  
  subject do
    supplier = create_supplier_card
    @factory = create_factory_card
    @factory << supplier
    @factory.putty
    supplier
  end
  let(:factory) { Card.gimme @factory.cardname }
  
  it 'delivers' do
    res = subject.deliver 
    res.should == card_content[:out]
  end
  
  
  context 'updated' do
    it 'updates file of related factory card' do
      subject.putty :content => card_content[:new_in]
      updated_factory  = Card.gimme factory.cardname
      path = factory.product_card.attach.path
      File.open(path) { |f| f.readlines.should == [card_content[:new_out]] }
    end
  end
  
  context 'removed' do
    it 'updates file of related factory card' do
      Card::Auth.as_bot do
        byebug
        subject.delete!
        byebug
      end
      byebug
      path = factory.product_card.attach.path
      File.open(path) { |f| f.readlines.should == [] }
    end
    it 'updates supplies card of related factory card' do
      Card::Auth.as_bot do
        subject.delete!
      end
      factory.supplies.item_card.should == []
    end
  end
end

