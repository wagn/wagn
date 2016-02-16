describe Card::StageDirector do
  describe 'abortion' do
    let(:create_card) { Card.create name: 'a card' }
    subject { Card.fetch 'a card' }
    context 'when error added' do
      it 'stops act in validation phase' do
        in_stage :validate,
                 on: :save,
                 trigger: -> { create_card } do
          errors.add :stop, "don't do this"
        end
        is_expected.to be_falsey
      end

      it 'does not stop act in storage phase' do
        in_stage :store, on: :save,
                         trigger: -> { create_card } do
          errors.add :stop, "don't do this"
        end
        is_expected.to be_truthy
      end
    end

    context 'when exception raised' do
      it 'rollbacks in finalize stage' do
        begin
          in_stage :finalize,
                   on: :save,
                   trigger: -> { create_card } do
            raise Card::Error, 'rollback'
          end
        rescue Card::Error => e
        ensure
          is_expected.to be_falsey
        end
      end

      it 'does not rollback in integrate stage' do
        begin
          Card::Auth.as_bot do
            in_stage :integrate,
                     on: :save,
                     trigger: -> { create_card } do
              raise Card::Abort, 'rollback'
            end
          end
        rescue Card::Abort => e
        ensure
          is_expected.to be_truthy
        end
      end
    end

    context 'when abort :success called' do
      it 'aborts storage in validation stage' do
        in_stage :validate,
                 on: :create,
                 trigger: -> { create_card } do
          abort :success
        end
        is_expected.to be_falsey
      end

      it 'aborts storage in store stage' do
        in_stage :store,
                 on: :create,
                 trigger: -> { create_card } do
          abort :success
        end
        is_expected.to be_falsey
      end

      it 'aborts storage in finalize stage' do
        in_stage :store,
                 on: :create,
                 trigger: -> { create_card } do
          abort :success
        end
        is_expected.to be_falsey
      end

      it 'does not abort storage in integrate stage' do
        in_stage :integrate,
                 on: :create,
                 trigger: -> { create_card } do
          abort :success
        end
        is_expected.to be_truthy
      end
    end
  end

  describe 'stage order' do
    let(:create_card_with_subcards) do
      Card.create name: '1',
                  subcards: {
                    '11' => { subcards: { '111' => 'A' } },
                    '12' => { subcards: { '121' => 'A' } }
                  }
    end
    let(:preorder) { %w(1 11 111 12 121) }
    let(:postorder) { %w(111 11 121 12 1) }
    describe 'validate' do
      it 'is pre-order depth-first' do
        order = []
        in_stage :validate, on: :create,
                            trigger: -> { create_card_with_subcards } do
          order << name
        end
        expect(order).to eq(preorder)
      end

      it 'executes all validate stages before next stage' do
        order = []
        with_test_events do
          test_event :validate, on: :create do
            order << "v:#{name}"
          end
          test_event :prepare_to_store, on: :create do
            order << "pts:#{name}"
          end
          create_card_with_subcards
        end
        expect(order).to eq(
          %w(v:1 v:11 v:111 v:12 v:121 pts:1 pts:11 pts:111 pts:12 pts:121)
        )
      end
    end

    describe 'finalize' do
      it 'is post-order depth-first' do
        order = []
        in_stage :finalize, on: :create,
                            trigger: -> { create_card_with_subcards } do
          order << name
        end
        expect(order).to eq(postorder)
      end
    end

    describe 'store' do
      it 'is pre-order depth-first' do
        order = []
        in_stage :store, on: :create,
                         trigger: -> { create_card_with_subcards } do
          order << name
        end
        expect(order).to eq(preorder)
      end
    end

    describe 'store and finalize' do
      it 'executes finalize when all subcards are stored and finalized' do
        order = []
        with_test_events do
          test_event :store, on: :create do
            order << "store:#{name}"
          end
          test_event :finalize, on: :create do
            order << "finalize:#{name}"
          end
          create_card_with_subcards
        end
        expect(order).to eq(
          %w(store:1 store:11 store:111 finalize:111 finalize:11
             store:12 store:121 finalize:121 finalize:12 finalize:1)
        )
      end
    end

    describe 'complete run' do
      it 'is in correct order' do
        order = []
        with_test_events do
          test_event :initialize, on: :create do
            order << "i:#{name}"
          end
          test_event :prepare_to_validate, on: :create do
            order << "ptv:#{name}"
          end
          test_event :validate, on: :create do
            order << "v:#{name}"
            add_subcard '112v' if name == '11'
          end
          test_event :prepare_to_store, on: :create do
            order << "pts:#{name}"
          end
          test_event :store, on: :create do
            order << "s:#{name}"
          end
          test_event :finalize, on: :create do
            order << "f:#{name}"
          end
          test_event :integrate, on: :create do
            order << "ig:#{name}"
          end
          test_event :integrate_with_delay, on: :create do
            order << "igwd:#{name}"
          end
          create_card_with_subcards
        end
        expect(order).to eq(
          %w(
            i:1 i:11 i:111 i:12 i:121
            ptv:1 ptv:11 ptv:111 ptv:12 ptv:121
            v:1 v:11 v:111
            i:112v ptv:112v v:112v
            v:12 v:121
            pts:1 pts:11 pts:111 pts:112v pts:12 pts:121
            s:1 s:11 s:111 f:111 s:112v f:112v f:11 s:12 s:121 f:121 f:12 f:1
            ig:1 ig:11 ig:111 ig:112v ig:12 ig:121
            igwd:1 igwd:11 igwd:111 igwd:112v igwd:12 igwd:121
          )
        )
      end
    end
  end

  describe 'subcards' do
    it "has correct name if supercard's name get changed" do
      Card::Auth.as_bot do
        in_stage(:prepare_to_validate, on: :create,
                 trigger: -> do
                    Card.create! name:'hi', subcards: { '+sub' => 'some
content' }
                 end
        ) do
          self.name = 'main'
        end
        expect(Card['main+sub'].class).to eq(Card)
      end
    end
  end
end
