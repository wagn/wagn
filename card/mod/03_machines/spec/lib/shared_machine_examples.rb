# -*- encoding : utf-8 -*-

def that_produces type
  type
end

def method_missing m, *args, &block
  case m
  when /that_produces_(.+)/
    return Regexp.last_match(1)
  else
    super
  end
end

shared_examples_for "machine" do |filetype|
  context "machine is run" do
    before do
      machine.update_machine_output
    end

    it "has +machine_input card" do
      expect(machine.machine_input_card.real?).to be_truthy
    end
    it "has +machine_output card" do
      expect(machine.machine_output_card.real?).to be_truthy
    end
    it "generates #{filetype} file" do
      expect(machine.machine_output_path).to match(/\.#{filetype}$/)
    end
  end
end

shared_examples_for "content machine" do |filetype|
  it_should_behave_like "machine", that_produces(filetype) do
    let(:machine) { machine_card }
  end

  context "+machine_input card" do
    it "points to self" do
      Card::Auth.as_bot do
        machine_card.update_input_card
      end
      expect(machine_card.input_item_cards).to eq([machine_card])
    end
  end

  context "+machine_output card" do
    it "creates file with supplied content" do
      path = machine_card.machine_output_path
      expect(File.read(path)).to eq(card_content[:out])
    end
    it "updates #{filetype} file when content is changed" do
      changed_factory = machine_card
      changed_factory.putty content: card_content[:changed_in]
      changed_path = changed_factory.machine_output_path
      expect(File.read(changed_path)).to eq(card_content[:changed_out])
    end
  end
end

shared_examples_for "pointer machine" do |filetype|
  subject do
    # We build the following structure:
    #
    #  #{machine_card}
    #    |- expected_input_items (passed by the calling test if it prepopulates
    #                             the machine_card with some additional items)
    #    |_ level 0 #{filetype}
    #         |- level 1 basic 1
    #         |- level 1 #{filetype}
    #         |    |- level 2 basic 1
    #         |    |- level 2 #{filetype}
    #         |    |    |_ ....
    #         |    |_ level 2 basic 2
    #         |_ level 1 basic 2
    #

    change_machine = machine_card
    @depth = 2
    @leaf_items = []
    @expected_items = expected_input_items || []
    start = @expected_items.size
    Card::Auth.as_bot do
      @depth.times do |i|
        @leaf_items << Card.fetch("level #{i} basic 1",
                                  new: { type: Card::BasicID })
        @leaf_items.last.save
        @leaf_items << Card.fetch("level #{i} basic 2",
                                  new: { type: Card::BasicID })
        @leaf_items.last.save
      end

      # we build the tree from bottom up
      last_level = false
      (@depth - 1).downto(0) do |i|
        next_level = Card.fetch("level #{i} #{filetype} ",
                                new: { type: :pointer })
        next_level.content = ""
        next_level << @leaf_items[i * 2]
        next_level << last_level if last_level
        next_level << @leaf_items[i * 2 + 1]
        next_level.save!
        @expected_items.insert(start, @leaf_items[i * 2])
        @expected_items.insert(start + 1, last_level) if last_level
        @expected_items << @leaf_items[i * 2 + 1]
        last_level = next_level
      end
      change_machine << last_level
      @expected_items.insert(start, last_level)
      change_machine << machine_input_card
      @expected_items << machine_input_card
      change_machine.save!
    end
    change_machine
  end

  it_should_behave_like "machine", that_produces(filetype) do
    let(:machine) { machine_card }
  end

  describe "+machine_input card" do
    before do
      Card::Auth.as_bot do
        subject.update_input_card
      end
    end

    it "contains items of all levels" do
      expect(subject.machine_input_card.item_cards.map(&:id).sort)
        .to eq(@expected_items.map(&:id).sort)
    end

    it "preserves order of items" do
      expect(subject.machine_input_card.item_cards.map(&:id))
        .to eq(@expected_items.map(&:id))
    end
  end

  describe "+machine_output card" do
    it 'creates #{filetype} file with supplied content' do
      path = subject.machine_output_path
      expect(File.read(path)).to eq(card_content[:out])
    end

    it 'updates #{filetype} file if item is changed' do
      machine_input_card.putty content: card_content[:changed_in]
      changed_path = subject.machine_output_path
      expect(File.read(changed_path)).to eq(card_content[:changed_out])
    end

    it 'updates #{filetype} file if item is added' do
      Card::Auth.as_bot do
        ca = Card.gimme! "pointer item", type: Card::SkinID, content: ""
        subject.items = [ca]
        ca << another_machine_input_card
        ca.save!
        changed_path = subject.machine_output_path
        expect(File.read(changed_path)).to eq(card_content[:new_out])
      end
    end

    context "a non-existent card was added as item and now created" do
      it 'updates #{filetype} file' do
        Card::Auth.as_bot do
          subject.content = "[[non-existent input]]"
          subject.save!
          ca = Card.gimme! "non-existent input",
                           type: input_type,
                           content: card_content[:changed_in]
          ca.save!
          changed_path = subject.machine_output_path
          input_name = machine_input_card.name
          out =
            card_content[:changed_out].gsub(input_name, 'non-existent input')
          expect(File.read(changed_path)).to eq(out)
        end
      end
    end
  end
end
