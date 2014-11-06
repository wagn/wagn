shared_examples_for 'notifications' do
  describe '#change_notice' do
    context 'for new card with subcards' do
      name = "another card with subcards"
      content = "main content {{+s1}}  {{+s2}}"
      sub1_content = 'new content of subcard 1'
      sub2_content = 'new content of subcard 2'
      before do
        Card::Auth.as_bot do
          @card = Card.create!(:name=>name, :content=>content, 
                               :subcards=>{ '+s1'=>{:content=>sub1_content}, 
                                            '+s2'=>{:content=>sub2_content} })
        end
      end
      subject { @card.format(:format=>format).render_change_notice }
      it { is_expected.to include content }
      it { is_expected.to include sub1_content }
      it { is_expected.to include sub2_content }
      
      context 'and missing permissions' do
        subject { Card.fetch(@card.name).format(:format=>format).render_change_notice }
        context 'for subcard' do
          before do
            Card.create_or_update! "#{name}+s1+*self+*read",:type=>'Pointer',:content=>'[[Administrator]]'
          end
          it "excludes subcard content" do
            Card::Auth.as(:joe_user) do
              is_expected.not_to include sub1_content
              is_expected.to include sub2_content
            end
          end
        end
        context 'for main card' do
          before do
            Card.create_or_update! "#{name}+*self+*read",:type=>'Pointer',:content=>'[[Administrator]]'
            Card.create_or_update! "#{name}+s1+*self+*read",:type=>'Pointer',:content=>'[[Anyone]]'
          end
          it 'includes subcard content' do
            Card::Auth.as(:joe_user) do
              is_expected.to include sub1_content
           end
         end
          it "excludes maincard content" do
            Card::Auth.as(:joe_user) do
              is_expected.not_to include content
              is_expected.not_to be_empty
            end
          end
        end
        context 'for all parts' do
          before do
            #Card.create_or_update! "#{name}+s1+*self+*read",:type=>'Pointer',:content=>'[[Administrator]]'
            #Card.create_or_update! "#{name}+s2+*self+*read",:type=>'Pointer',:content=>'[[Administrator]]'
            Card.create_or_update! "s1+*self+*read",:type=>'Pointer',:content=>'[[Administrator]]'
            Card.create_or_update! "s2+*self+*read",:type=>'Pointer',:content=>'[[Administrator]]'
            Card.create_or_update! "#{name}+*self+*read",:type=>'Pointer',:content=>'[[Administrator]]'
          end
          it { is_expected.to be_empty }
        end
      end
    end
  end

  describe '#list_of_changes' do
    name = 'subedit notice'
    content = 'new content'
    
    before do
      @card = Card.create!(:name=>name, :content=>content)
    end
    subject { @card.format(:format=>format).render_list_of_changes }
    
    context 'for a new card' do
      it { is_expected.to include "content: #{content}" }
      it { is_expected.to include 'cardtype: Basic' }
    end
    context 'for a updated card' do
      before { @card.update_attributes!(:name=>'bnn card', :type=>:pointer, :content=>'changed content') }
      it { is_expected.to include 'new content: [[changed content]]' }
      it { is_expected.to include 'new cardtype: Pointer' }
      it { is_expected.to include 'new name: bnn card' }
    end
    context 'for a deleted card' do
      before { @card.delete }
      it { is_expected.to be_empty }
    end
    
    context 'for a given action' do
      subject do
        action = @card.last_action
        @card.update_attributes!(:name=>'bnn card', :type=>:pointer, :content=>'changed content')
        @card.format(:format=>format).render_list_of_changes(:action=>action)
      end
      it { is_expected.to include "content: #{content}" }
    end
    context 'for a given action id' do
      subject do
        action_id = @card.last_action.id
        @card.update_attributes!(:name=>'bnn card', :type=>:pointer, :content=>'changed content')
        @card.format(:format=>format).render_list_of_changes(:action_id=>action_id)
      end
      it { is_expected.to include "content: #{content}" }
    end
  end
  
  describe 'subedit_notice' do
    def list_of_changes_for card
      card.db_content
    end
    name = 'subedit notice card'
    content = 'new content'
    before do
      @card = Card.create!(:name=>name, :content=>content)
    end
    subject { @card.format(:format=>format).render_subedit_notice }
    
    context 'for a new card' do
      it { is_expected.to include name }
      it { is_expected.to include 'created' }
      it { is_expected.to include list_of_changes_for @card }
    end
    
    context 'for a updated card' do
      changed_name = 'changed subedit notice'
      changed_content = 'changed content'
      before { @card.update_attributes!(:name=>changed_name, :content=>changed_content) }
      it { is_expected.to include changed_name }
      it { is_expected.to include 'updated' }
      it { is_expected.to include list_of_changes_for @card }
    end
    
    context 'for a deleted card' do
      before { @card.delete } 
      it { is_expected.to include name }
      it { is_expected.to include 'deleted' }
    end
  end
end


describe Card::Set::All::Notify do
  describe 'html format' do
    include_examples 'notifications' do
      let(:format) { 'email_html' }
    end
    
    it 'contains html' do
      card = Card.create! :name=>'new card'
      expect(card.format(:format=>:email_html).render_change_notice).to include '<p>'
    end
  end
  
  describe 'text format' do
    include_examples 'notifications' do
      let(:format) { 'email_text' }
    end
    it 'does not contain html' do
      card = Card.create! :name=>'new card'
      expect(card.format(:format=>:email_text).render_change_notice).not_to match /<\w+>/
    end
    it 'creates well formatted text message' do
      name = "another card with subcards"
      content = "main content {{+s1}}  {{+s2}}"
      sub1_content = 'new content of subcard 1'
      sub2_content = 'new content of subcard 2'
      Card::Auth.as_bot do
        @card = Card.create!(:name=>name, :content=>content,
                             :subcards=>{ '+s1'=>{:content=>sub1_content},
                                          '+s2'=>{:content=>sub2_content} })
      end
      result =  @card.format(:format=>:email_text).render_change_notice
      expect(result).to eq(%{Dear My Wagn user

"another card with subcards"
was just created by Joe User
   cardtype: Basic
   content: main content {{+s1}}  {{+s2}}

This update included the following changes:

another card with subcards+s1 created
   cardtype: Basic
   content: new content of subcard 1


another card with subcards+s2 created
   cardtype: Basic
   content: new content of subcard 2


See the card: /another_card_with_subcards

You received this email because you're following "".
Visit /update/+*following?drop_item= to stop receiving these emails.})
    end
  end
end
