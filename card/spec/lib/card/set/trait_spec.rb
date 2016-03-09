
describe Card::Set::Trait do
  class Card; module Set; module Type; module Phrase
    extend Card::Set
    card_accessor :write, type: 'pointer'
    card_accessor :read, type_id: Card::PointerID
  end; end; end; end

  class Card; module Set; module TypePlusRight; module Phrase; module Write
    extend Card::Set
    def type_plus_right_module_loaded
      true
    end
  end; end; end; end; end

  subject do
    Card::Auth.as_bot do
      Card.create! name: 'joke',
                   type_id: Card::PhraseID,
                   '+*write' => 'some content',
                   '+*read' => 'some content'
    end
  end

  context 'if accessor type is defined by a string' do
    it 'has left' do
      in_stage :prepare_to_validate, on: :create,
               trigger: -> { subject } do
        # test API doesn't support sets for event
        # so we check the name
        return unless name == 'joke'
        expect(write_card.left.class).to eq Card
      end
    end
    it 'loads *type plus right set module' do
      in_stage :prepare_to_validate, on: :create,
               trigger: -> { subject } do
        return unless name == 'joke'
        expect(write_card).to respond_to?(:type_plus_right_module_loaded)
      end
    end
  end
  context 'if accessor type is defined by an id' do
    it 'has left' do
      in_stage :prepare_to_validate, on: :create,
               trigger: -> { subject } do
        return unless name == 'joke'
        expect(read_card.left.class).to eq Card
      end
    end
  end
end