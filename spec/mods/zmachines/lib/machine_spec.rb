
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


shared_examples_for 'machine' do |filetype|
  context "when created" do
    it 'has +machine_input card' do
      machine.machine_input_card.should_not be_nil
    end
    it 'has +machine_output card' do
      machine.machine_output_card.should_not be_nil
    end
    it "generates #{filetype} file" do
      expect(machine.machine_output_path).to match(/\.#{filetype}$/)
    end
  end
end

shared_examples_for 'content machine' do |filetype|
  it_should_behave_like 'machine', that_produces(filetype) do
    let(:machine) { machine_card }
  end
  
  context '+machine_input card' do
    it "points to self" do
      expect(machine_card.input_item_cards).to eq([machine_card])
    end
  end
  
  context '+machine_output card' do
    it 'creates file with supplied content' do
      path = machine_card.machine_output_path
      expect(File.read(path)).to eq(card_content[:out])
    end
    it "updates #{filetype} file when content is changed" do
      changed_factory = machine_card
      changed_factory.putty :content =>card_content[:new_in]
      changed_path = changed_factory.machine_output_path
      expect(File.read(changed_path)).to eq(card_content[:new_out])
    end
  end
end


shared_examples_for 'pointer machine' do |filetype|
  subject do
    change_machine = machine_card
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
      change_machine << last_level
      change_machine << machine_input_card
      @expected_items << machine_input_card
      change_machine.save!
    end
    change_machine
  end

  it_should_behave_like 'machine', that_produces(filetype) do
    let(:machine) { machine_card }
  end
  
  describe '+machine_input card' do
    it "contains items of all levels" do
      subject.machine_input_card.item_cards.map(&:id).sort.should == @expected_items.map(&:id).sort
    end
    
    it "preserves order of items" do
      subject.machine_input_card.item_cards.map(&:id).should == @expected_items.map(&:id)
    end
  end
  
  describe '+machine_output card' do
    it 'creates #{filetype} file with supplied content' do
      path = subject.machine_output_path
      expect(File.read(path)).to eq(card_content[:out])
    end
    
    it 'updates #{filetype} file if item is changed' do
      machine_input_card.putty :content => card_content[:new_in]
      changed_path = subject.machine_output_path
      expect(File.read(changed_path)).to eq(card_content[:new_out])
    end
  end
end
