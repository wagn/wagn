describe "act API" do
  let(:create_card) { Card.create!(name: "main card") }
  let(:create_card_with_subcards) do
    Card.create name: "main card",
                subcards: {
                  "11" => { subcards: { "111" => "A" } },
                  "12" => { subcards: { "121" => "A" } }
                }
  end

  describe "add subcard in integrate stage" do
    class Card
      def current_trans
        ActiveRecord::Base.connection.current_transaction
      end

      def record_names
        current_trans.records.map(&:name)
      end
    end

    context "default subcard handling" do
      it "processes all cards in one transaction" do
        with_test_events do
          test_event :validate, on: :create, for: "main card" do
            add_subcard("sub card")
          end

          test_event :finalize, on: :create, for: "main card" do
            expect(record_names).to eq ["main card", "sub card"]
          end

          create_card
        end
      end
    end

    context "serial subcard handling" do
      it "processes subcards in separate transaction" do
        Delayed::Worker.delay_jobs = true
        with_test_events do
          test_event :validate, on: :create, for: "main card" do
            add_subcard("sub card", transact_in_stage: :integrate_with_delay)
            # expect(subcard('sub card').director.transact_in_stage)
            #  .to eq :integrate
          end

          test_event :finalize, on: :create, for: "main card" do
            expect(record_names).to eq ["main card"]
            expect(subcard("sub card").director.stage).to eq nil
          end

          test_event :integrate, on: :create, for: "main card" do
            expect(record_names).to eq []
            expect(subcard("sub card").director.stage).to eq nil
          end

          test_event :finalize, on: :create, for: "sub card" do
            expect(record_names).to eq ["sub card"]
          end

          test_event :integrate_with_delay, on: :create do
            expect(record_names).to eq []
          end
          create_card
          # expect to finished delayed jobs
          expect(Delayed::Worker.new.work_off).to eq [2, 0]
          expect(Card["sub card"]).to be_instance_of(Card)
        end
      end
    end
  end

  describe "dirty attributes" do
    it "survives to integration phase" do
      Delayed::Worker.delay_jobs = true
      with_test_events do
        test_event :validate do
          self.content = "new content"
        end
        test_event :integrate do
          expect(name_changed?).to be_truthy
          expect(changes["name"]).to eq(["A", "new name"])
          expect(changes["db_content"]).to eq(["Alpha [[Z]]",  "new content"])
        end
        test_event :integrate_with_delay do
          expect(name_changed?).to be_truthy
          expect(changes["name"]).to eq(["A", "new name"])
          expect(changes["db_content"]).to eq(["Alpha [[Z]]",  "new content"])
        end
        Delayed::Worker.new.work_off
        Card["A"].update_attributes! name: "new name"
      end
    end

    it '"changed" option works in integration phase' do
      @called_events = []
      def event_called ev
        @called_events << ev
      end

      with_test_events do
        test_event :integrate, changed: :name do
          event_called :i_name
        end
        test_event :integrate, changed: :content do
          event_called :i_content
        end
        test_event :integrate_with_delay, changed: :name do
          event_called :iwd_name
        end
        test_event :integrate_with_delay, changed: :content do
          event_called :iwd_content
        end
        Card["A"].update_attributes! name: "new name"
      end
      expect(@called_events).to eq([:i_name, :iwd_name])
    end
  end

  describe "Env" do
    it "survives to integration phase" do
      Delayed::Worker.delay_jobs = true
      with_test_events do
        test_event :initialize, on: :create do
          Card::Env.root("new root")
        end
        test_event :integrate, on: :create do
          expect(Card::Env.root).to eq("new root")
        end
        test_event :integrate_with_delay, on: :create do
          expect(Card::Env.root).to eq("new root")
        end
        create_card
        Delayed::Worker.new.work_off
      end
    end
  end
end
