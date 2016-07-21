describe 'act API' do
  let(:create_card) { Card.create!(name: 'main card') }
  let(:create_card_with_subcards) do
    Card.create name: 'main card',
                subcards: {
                  '11' => { subcards: { '111' => 'A' } },
                  '12' => { subcards: { '121' => 'A' } }
                }
  end


  describe 'add subcard in integrate stage' do
    class Card
      def current_trans
        ActiveRecord::Base.connection.current_transaction
      end
      def record_names
        current_trans.records.map(&:name)
      end
    end

    context 'default subcard handling' do
      it 'processes all cards in one transaction' do
        with_test_events do
          test_event :validate, on: :create, for: 'main card' do
            add_subcard('sub card')
          end

          test_event :store, on: :create, for: 'main card' do
            expect(record_names).to eq ['main card', 'sub card']
          end

          create_card
        end
      end
    end

    context 'serial subcard handling' do
      it 'processes subcards in separate transaction' do

        $rspec_trans = ActiveRecord::Base.connection.current_transaction
        with_test_events do
          test_event :validate, on: :create, for: 'main card' do
            Card::Env.host('new root')
            $trans = current_trans

            expect(Card['sub card']).to be_falsey
            binding.pry
            add_subcard('sub card', transact_in_stage: :integrate)

            expect(subcard('sub card').director.transact_in_stage)
              .to eq :integrate
          end

          test_event :integrate, on: :create, for: 'main card' do
            #expect($rspec_trans).to eq current_trans
            expect(subcard('sub card').director.stage).to eq nil
          end

          test_event :finalize, on: :create, for: 'main card' do
            #expect(@trans).to eq ActiveRecord::Base.connection.current_transaction
            expect($trans).to eq current_trans
            expect(subcard('sub card').director.stage).to eq nil
          end

          test_event :finalize, on: :create, for: 'sub card' do
            ct = current_trans
            expect($trans).not_to eq ct
          end
        end
        test_event :integrate_with_delay, on: :create do
          expect($rspec_trans).to eq current_trans
          expect(Card::Env.host).to eq('new root')
        end
        create_card
        # expect to finished delayed jobs
        expect(Delayed::Worker.new.work_off).to eq [2, 0]
        #expect(Delayed::Worker.new.work_off).to eq [1, 0]
        expect(Card['sub card']).to be_instance_of(Card)
      end
    end

    context 'transaction turned on' do
      def expect_new_transaction
        expect($trans).not_to eq current_trans
      end

      def expect_no_transaction
        expect(@rspec_trans).to eq current_trans
      end

      def expect_same_transaction
        expect($trans).to eq current_trans
      end

      def check_transaction stage, val
        Card::Auth.as_bot do
          in_stage stage, trigger: -> { create_card } do
            if name == 'check trans'
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
    it 'unchanged in integration phase' do

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
