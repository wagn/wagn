# -*- encoding : utf-8 -*-

describe Card::Set::Type::ListedBy do
  let(:list) { Card.fetch("A+books").item_names.sort }
  before do
    Card::Auth.as_bot do
      Card.create! :name=>'Perry Hotter', :type=>'book', :subcards=>{'+basics'=>{:content=>"[[A]]", :type=>'list'}}
      Card.create! :name=>'50 grades of shy' , :type=>'book', :subcards=>{'+basics'=>{:content=>"[[A]]\n[[B]]", :type=>'list'}}
    end
  end
  context "when A is listed by 'Perry Hotter' and '50 grades of shy'" do
    before do
      Card.create! :name=>'A+books', :type=>'listed by'
    end
    describe 'cached content' do
      subject { list }
      it { is_expected.to eq ['50 grades of shy','Perry Hotter'] }

      context "when A is removed from Perry Hotter's list" do
        before do
          Card['Perry Hotter+basics'].update_attributes! :content=>'[[B]]'
        end
        it { is_expected.to eq ['50 grades of shy'] }
      end
      context 'when a Perry Hotter is deleted' do
        before do
          Card['Perry Hotter'].delete
        end
        it { is_expected.to eq ['50 grades of shy'] }
      end
      context 'when a new book is created that lists A' do
        before do
          Card::Auth.as_bot do
            Card.create! :name=>'Adventures of Buckleharry Finn', :type=>'book', :subcards=>{'+basics'=>{:content=>"[[A]]", :type=>'list'}}
          end
        end
        it { is_expected.to eq ['50 grades of shy', 'Adventures of Buckleharry Finn', 'Perry Hotter'] }
      end
      context "when A is added to a book's list" do
        before do
          Card::Auth.as_bot do
            Card.create! :name=>'Adventures of Buckleharry Finn', :type=>'book', :subcards=>{'+basics'=>{:content=>"[[B]]", :type=>'list'}}
            Card.fetch('Adventures of Buckleharry Finn+basics').update_attributes! :content=>'[[A]]'
          end
        end
        it { is_expected.to eq ['50 grades of shy', 'Adventures of Buckleharry Finn', 'Perry Hotter'] }
      end

      context 'when the cardtype of Perry Hotter changed' do
        before do
          Card['50 grades of shy'].update_attributes! :type_id => Card::BasicID
        end
        it { is_expected.to eq ['50 grades of shy'] }
      end
      context 'when the name of Perry Hotter changed to Parry Moppins' do
        before do
          Card['Perry Hotter'].update_attributes! :name => 'Parry Moppins'
        end
        it { is_expected.to eq ['50 grades of shy','Perry Moppins'] }
      end
      context 'when the name of Perry Hotter+basics changed' do
        before do
          Card['Perry Hotter+basics'].update_attributes! :name => 'Perry Hotter+hidden'
        end
        it { is_expected.to eq ['50 grades of shy'] }
      end
      context 'when the name of A changed' do
        before do
          Card['A'].update_attributes! :name=>'G'
        end
        it { is_expected.to eq ['Perry Hotter', '50 grades of shy'] }
      end
      context 'when the name of A+books changed' do
        before do
          Card['A+books'].update_attributes! :name=>'A+basics'
        end
        it { is_expected.to eq [] }
      end
      context 'when the name of the cardtype books changed' do
        before do
          Card['50 grades of shy'].update_attributes! :type_id => Card::BasicID
        end
        it { is_expected.to eq ['Perry Hotter'] }
      end
      context 'when the name of the cardtype basics changed' do
        before do
          Card['50 grades of shy'].update_attributes! :type_id => Card::BasicID
        end
        it { is_expected.to eq ['Perry Hotter'] }
      end
    end
    # context 'and a book is added to A' do
    #   it "updates the book's list" do
    #     Card::Auth.as_bot do
    #       Card.create! :name=>'Adventures of Buckleharry Finn', :type=>'book', :subcards=>{'+basics'=>{:content=>"", :type=>'list'}}
    #       Card['A+books'].update_attributes! :content=>"[[Adventures of Buckleharry Finn]]"
    #     end
    #     expect(content).to eq("[[Perry Hotter]]\n[[50 grades of shy]]\n[[Adventures of Buckleharry Finn]]")
    #     expect(Card['Adventures of Buckleharry Finn'].content).to eq('[[A]]')
    #   end
    # end
  end

end