describe 'act API' do
  let(:create_card) { Card.create!(name: 'check trans') }
  let(:create_card_with_subcards) do
    Card.create name: 'main card',
                subcards: {
                  '11' => { subcards: { '111' => 'A' } },
                  '12' => { subcards: { '121' => 'A' } }
                }
  end

  describe 'transactions' do
    context 'transaction turned on' do
      it 'initialization phase is outside transaction' do
        check_transaction :initialize, be_falsey
      end

      it 'validation phase is inside transaction' do
        check_transaction :validate, be_truthy
      end

      it 'storage phase is inside transaction' do
        check_transaction :store, be_truthy
      end

      it 'integration phase is outside transaction' do
        # Card::Auth.as_bot do
        #   Card.create! name: 'integrate me'
        # end
        check_transaction :integrate, be_falsey
      end

      def check_transaction stage, val
        Card::Auth.as_bot do
          in_stage stage, trigger: -> { create_card } do
            if name == 'check trans'
              binding.pry
              expect(transaction_record_state(:new_record)).to val
            end
          end
        end
      end
    end

    context 'transaction turned off' do
      def check_transaction stage, val
        with_test_events do
          test_event :initialize, on: :create do
            if name == 'main card'
              transaction :off
              subcard_staging
            else

            end
          end
          test_event :validate, on: :create do
            case name
            when 'main card'
              expect(transaction_record_state(:new_record)).to be_falsey
            else
              expect(transaction_record_state(:new_record)).to be_truthy
            end
          end
          test_event :finalize, on: :create do
            case name
            when 'main card'
              expect(transaction_record_state(:new_record)).to be_falsey
            else
              expect(transaction_record_state(:new_record)).to be_truthy
            end
          end
          test_event :integrate, on: :create do
            expect(transaction_record_state(:new_record)).to be_falsey
          end

        end

        Card::Auth.as_bot do
          in_stage stage, trigger: -> { create_card } do
            if name == 'check trans'
              expect(transaction_record_state(:new_record)).to val
            end
          end
        end
      end
    end
  end

  describe 'dirty' do
    context 'with transaction' do

    end

    context 'without transaction' do

    end
  end

  describe 'Env' do
    it 'is available in integrate_with_delay stage' do
      with_test_events do
        test_event :initialize, on: :create do
          Env.root = 'new root'
        end
        test_event :integrate, on: :create do
          expect(Env.root).to eq('new root')
        end
        test_event :integrate_with_delay, on: :create do
          expect(Env.root).to eq('new root')
        end
        create_card
      end
    end
  end
end