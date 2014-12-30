# -*- encoding : utf-8 -*-
describe Card::Set::All::History do
  context "history view" do
    # before do
    #   Card.create! :name=>"my histoer card"
    # end
    it 'should have a frame' do
      history = render_card :history, :name=>"A"
      assert_view_select history, 'div[class~="card-frame"]'
    end
    
    
    describe '#action_summary' do
      subject do 
        first = Card.fetch('First')
        first.format.render_action_summary
      end
      it 'should have a summary' do
        assert_view_select subject, 'del[class="diffdel diff-red"]', :text=>'chicken' 
        assert_view_select subject, 'ins[class="diffins diff-green"]', :text=>'chick'         
      end
    end
  end
  
  
  describe '#create_act_and_action' do
    let!(:act_start_cnt) {Card::Act.count}
    let(:content)        {"Nobody expects the Spanish inquisition"}
    let(:act)            {@card.acts.last}
    let(:action)         {act.actions.last}
    
    context 'for single card' do
      before do
        @card = Card::Auth.as_bot do
          Card.create :name=>"single card", :content=>content
        end
      end
        
      context 'when created' do
        it 'adds new act' do
          expect(Card::Act.count).to eq(act_start_cnt+1)
          expect(act.card_id).to eq(@card.id)
        end
        it 'adds create action' do
          expect(action.action_type).to eq(:create)
        end
      end
      
      context 'when updated' do
        it 'adds no act if nothing changed' do
          @card.update_attributes  :name=>"single card", :content=>content
          expect(Card::Act.count).to eq(act_start_cnt+1)
        end
        it 'adds new act' do
          @card.update_attributes :content=>"new content"
          expect(Card::Act.count).to eq(act_start_cnt+2)
        end
      end
      
      context 'when deleted' do
        before do
          Card::Auth.as_bot do
            @card.delete
          end
        end
        it 'adds act' do
          expect(Card::Act.count).to eq(act_start_cnt+2)
        end
        it 'adds delete action' do
          expect(action.action_type).to eq(:delete)
        end  
        it 'adds trash change' do  
          expect(action.changes.last.field).to eq('trash')
          expect(action.changes.last.value).to be_truthy
        end
      end
    end

    context 'for subcard' do
      before do
        Card::Auth.as_bot do
          @card = Card.create :name=>"left", :subcards=>{"+right" =>{ :content=>content}}
          @left_action = act.actions[0]
          @right_action = act.actions[2]
          @plus_action = act.actions[1]
        end
      end
    
      context 'when created' do
        it 'adds only a act for left card' do
          expect(Card::Act.count).to eq(act_start_cnt+1)
          expect(act.card).to eq(@card)
        end
    
        it 'adds three actions' do
          expect(act.actions.size).to eq(3)
        end
        it 'adds action for left part of type create' do
          expect(@left_action.card.name).to eq("left")
          expect(@left_action.action_type).to eq(:create)
        end
        it 'adds action for right part of type create' do
          expect(@right_action.card.name).to eq("right")
          expect(@right_action.action_type).to eq(:create)
        end
        it 'adds action for plus card of type create' do
          expect(@plus_action.card.name).to eq("left+right")
          expect(@plus_action.action_type).to eq(:create)
        end
        it 'adds content change' do
          expect(@plus_action.changes.find_by_field(:db_content).value).to eq(content)
        end
        it 'adds superaction for plus card' do
          expect(@plus_action.super_action_id).to eq(@left_action.id)
        end
      end
      
      context 'when updated' do
        it 'adds act for left card' do
          @card.update_attributes :subcards=>{"+right"=>{:content=>"New content", :db_content=>"New Content"}}
          expect(Card::Act.count).to eq(act_start_cnt+2)
          expect(act.card).to eq(@card)
        end
        it 'adds action for subcard' do
          @card.update_attributes :subcards=>{"+right"=>{:content=>"New content", :content=>"New Content"}}
          act = @card.acts.last
          expect(act.actions.count).to eq(1)
          expect(act.actions.last.action_type).to eq(:update)
          expect(act.actions.last.card.name).to eq("left+right")
        end
      end
    end
    
    context 'for plus card' do
      before do
        Card::Auth.as_bot do
          @card = Card.create :name=>'left+right', :content=>content
          @left_action = act.actions[1]
          @plus_action = act.actions[0]
          @right_action = act.actions[2]
        end
      end
      
      context 'adds' do
        it 'only a act for plus card' do
          expect(Card::Act.count).to eq(act_start_cnt+1)
          expect(act.card_id).to eq(@card.id)
        end
        it 'three actions' do
          expect(act.actions.size).to eq(3)
        end            
        it 'action for left part of type create' do
          expect(@left_action.card.name).to eq("left")
          expect(@left_action.action_type).to eq(:create)
        end
        it 'superaction for left part' do
          expect(@left_action.super_action_id).to eq(@plus_action.id)
        end
        it 'action for right part of type create' do
          expect(@right_action.card.name).to eq("right")
          expect(@right_action.action_type).to eq(:create)
        end
        it 'action for plus card of type create' do
          expect(@plus_action.card.name).to eq("left+right")
          expect(@plus_action.action_type).to eq(:create)
        end   
        it 'content change' do
          expect(@plus_action.changes.find_by_field(:db_content).value).to eq(content)
        end
      end
    end
  end
end
