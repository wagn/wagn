# -*- encoding : utf-8 -*-

describe Card::Set::Type::List do
  let(:list) { Card.fetch("Parry Hotter+authors").item_names.sort }
  before do
    Card::Auth.as_bot do
      Card.create! :name=>'Parry Hotter+authors', :content=>"[[Darles Chickens]]\n[[Stam Broker]]", :type=>'list'
      Card.create! :name=>'Stam Broker+books', :type=>'listed by'
    end
  end
  describe 'Parry Hotter+authors' do
    subject { list }
    context "when 'Parry Hotter' is added to Joe-Ann Rolwings's books" do
      before do
        Card.create! :name=>'Joe-Ann Rolwing', :type=>'author'
        Card.create! :name=>'Joe-Ann Rolwing+books', :type=>'listed by'
        Card['Joe-Ann Rolwing+books'].add_item! 'Parry Hotter'
      end
      it { is_expected.to eq ['Darles Chickens', 'Joe-Ann Rolwing', 'Stam Broker'] }
    end

    context "when 'Parry Hotter' is dropped from Stam Brokers's books" do
      before do
        Card['Stam Brokers+books'].drop_item! 'Parry Hotter'
      end
      it { is_expected.to eq ['Darles Chickens'] }
    end
    context "when Stam Broker is deleted" do
      before do
        Card['Stam Broker'].delete
      end
      it { is_expected.to eq ['Darles Chickens', 'Stam Broker'] }  # should it change
    end
    context 'when the cardtype of Stam Broker changed' do
      before do
        Card['Stam Broker'].update_attributes! :type_id => Card::BasicID
      end
      it { is_expected.to eq ['Darles Chickens'] }
    end
    context 'when the name of Stam Broker changed to Parry Moppins' do
      before do
        Card['Parry Hotter'].update_attributes! :name => 'Parry Moppins'
      end
      it { is_expected.to eq ['Darles Chickens','Parry Moppins'] }
    end

    context 'when the name of Stam Broker changed' do
      before do
        Card['Stam Broker'].update_attributes! :name=>'Stam Trader'
      end
      it { is_expected.to eq ['Darles Chickens', 'Stam Trader'] }
    end

    context 'when Stam Broker+books changes to Stam Broker+poems' do # if content is invalid then fail
      it 'raises error because content is invalid' do
        expect do
          Card['Stam Broker+books'].update_attributes! :name=>'Stam Broker+poems'
        end.to raise_error
      end
    end
    context 'when Stam Broker+books changes to Stam Broker+not a type' do
      it 'raises error because name needs cardtype name as right part' do
        expect do
          Card['Stam Broker+books'].update_attributes! :name=>'Stam Broker+not a type'
        end.to raise_error
      end
    end

    context 'when the cartype of Parry Hotter changed' do
      before do
        Card['Parry Hotter'].update_attributes! :type_id=>Card::BasicID
      end
      it { is_expected.to eq ['Darles Chickens', 'Stam Trader'] }
    end
    context 'when Parry Hotter+authors to Parry Hotter+dancers' do
      it 'raises error because content is invalid' do
        expect do
          Card['Parry Hotter'].update_attributes! :name=>'Parry Hotter+basics'
        end.to raise_error
      end
    end

  end
  describe "'listed by' entry added that doesn't have a list" do
    context "when '50 grades of shy is added to Stam Broker's books" do
      before do
        Card['Stam Broker+books'].add_item! '50 grades of shy'
      end
      it "creates '50 grades of shy+authors" do
        authors = Card['50 grades of shy+authors']
        expect(authors).to be_truthy
        expect(authors.item_names).to eq ['Stam Broker']
      end
    end
  end
  context 'when a new author is created that lists Darles Chickens' do
    before do
      Card::Auth.as_bot do
        Card.create! :name=>'Adventures of Buckleharry Finn', :type=>'book', :subcards=>{'+authors'=>{:content=>"[[Darles Chickens]]", :type=>'list'}}
      end
    end
    it { is_expected.to eq ['50 grades of shy', 'Adventures of Buckleharry Finn', 'Parry Hotter'] }
  end
  context "when Darles Chickens is added to a book's list" do
    before do
      Card::Auth.as_bot do
        Card.create! :name=>'Adventures of Buckleharry Finn', :type=>'book', :subcards=>{'+authors'=>{:content=>"[[Stam Broker]]", :type=>'list'}}
        Card.fetch('Adventures of Buckleharry Finn+authors').update_attributes! :content=>'[[Darles Chickens]]'
      end
    end
    it { is_expected.to eq ['50 grades of shy', 'Adventures of Buckleharry Finn', 'Parry Hotter'] }
  end


  context 'when the name of the cardtype books changed' do
    before do
      Card['book'].update_attributes! :type_id => Card::BasicID
    end
    it { is_expected.to eq [] }
  end
  context 'when the name of the cardtype authors changed' do
    before do
      Card['author'].update_attributes! :type_id => Card::BasicID
    end
    it { is_expected.to eq [] }
  end
end