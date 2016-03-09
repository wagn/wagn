
describe Card::Set::Trait do
  class Card; module Set; module Type; module Phrase
    extend Card::Set
    card_accessor :write, type: 'pointer'
    card_accessor :read, type_id: Card::PointerID
  end; end; end; end

  class Card; module Set; module TypePlusRight; module Phrase; module Write
    extend Card::Set
    def correct_set_module_loaded
      true
    end
  end; end; end; end; end

  subject do
    Card::Auth.as_bot do
      Card.create! name: 'joke+funny+Joe User', type_id: Card::PhraseID,
                   #type_id: Card::PhraseID,
                   subcards: {
                     '+*write' => 'some content',
                     '+*read' => 'some content'
                   }
    end
  end

  it 'has left if accessor type is defined by a string' do
    in_stage :prepare_to_validate, on: :create,
             trigger: -> { subject } do
      if type_id == Card::PhraseID
        expect(write_card.left.class).to eq Card
        expect(write_card).to respond_to(:correct_set_module_loaded)
      end
    end
  end

  it 'has left if accessor type is defined by an id' do
    in_stage :prepare_to_validate, on: :create,
             trigger: -> { subject } do
      if type_id == Card::PhraseID
        Card.fetch 'pointer'
        expect(read_card.left.class).to eq Card
      end
    end
  end

  # context "when left's type is defined by a string" do
  #   subject do
  #     Card::Auth.as_bot do
  #       Card.create! name: 'joke+funny+Joe User',
  #                    type: 'phrase',
  #                    subcards: {
  #                      '+*write' => 'some content',
  #                      '+*read' => 'some content'
  #                    }
  #     end
  #   end
  #   it 'has left if left type is defined by an id' do
  #
  #     in_stage :prepare_to_validate, on: :create,
  #              trigger: -> { subject } do
  #       if type_id == Card::PhraseID
  #         expect(read_card.left.class).to eq Card
  #       end
  #     end
  #   end
  # end
end
