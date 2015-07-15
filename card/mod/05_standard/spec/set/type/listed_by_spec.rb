# -*- encoding : utf-8 -*-

describe Card::Set::Type::ListedBy do
  let(:list) { Card.fetch("A+books").raw_content }
  before do
    Card::Auth.as_bot do
      Card.create! :name=>'Perry Hotter', :type=>'book', :subcards=>{'+basics'=>{:content=>"[[A]]", :type=>'list'}}
      Card.create! :name=>'50 grades of shy' , :type=>'book', :subcards=>{'+basics'=>{:content=>"[[A]]\n[[B]]", :type=>'list'}}
    end
  end
  context 'when A is listed by two books' do
    before do
      Card.create! :name=>'A+books', :type=>'listed by'
    end
    describe 'cached content' do
      subject { list }
      it { is_expected.to eq("[[Perry Hotter]]\n[[50 grades of shy]]") }
    end
    context "when A is removed from a book's list" do
      before do
        Card['Perry Hotter'].update_attributes! :content=>'[[B]]'
      end
      describe 'cached content' do
        subject { list }
        it { is_expected.to eq("[[50 grades of shy]]") }
      end
    end
    context 'when a book is deleted' do
      before do
        Card['Perry Hotter'].delete
      end
      describe '+*cached content' do
        subject { list }
        it { is_expected.to eq("[[50 grades of shy]]") }
      end
    end
    context 'when a book is created' do
      before do
        Card::Auth.as_bot do
          Card.create! :name=>'Adventures of Buckleharry Finn', :type=>'book', :subcards=>{'+basics'=>{:content=>"[[A]]", :type=>'list'}}
        end
      end
      describe '+*cached content' do
        subject { list }
        it { is_expected.to eq("[[Perry Hotter]]\n[[50 grades of shy]]\n[[Adventures of Buckleharry Finn]]") }
      end
    end
    context 'when the cardtype of a book is changed' do
      before do
        Card['50 grades of shy'].update_attributes! :type_code => :basic
      end
      describe '+*cached content' do
        subject { list }
        it { is_expected.to eq("[[Perry Hotter]]") }
      end
    end
    context 'when a book is added to A' do
      it "updates the book's list" do
        Card::Auth.as_bot do
          Card.create! :name=>'Adventures of Buckleharry Finn', :type=>'book', :subcards=>{'+basics'=>{:content=>"", :type=>'list'}}
          Card['A+books'].update_attributes! :content=>"[[Adventures of Buckleharry Finn]]"
        end
        expect(content).to eq("[[Perry Hotter]]\n[[50 grades of shy]]\n[[Adventures of Buckleharry Finn]]")
        expect(Card['Adventures of Buckleharry Finn'].content).to eq('[[A]]')
      end
    end
  end

end