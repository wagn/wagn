# -*- encoding : utf-8 -*-

describe Card do
  before do
    Timecop.travel(Card.future_stamp)  # make sure we're ahead of all the test data
    @just_s = [Card["Sara"].id]
    @s_and_j= [Card["Sara"].id, Card["John"].id].sort
  end
end


describe "Card::Set::All::Follow" do
 
  def expect_user user_name
    expect(Card.fetch(user_name).account)
  end

  def be_notified_of card_name
    receive(:send_change_notice).with(kind_of(Card::Act), card_name)
  end

  context "when following cards" do
    before do
      Card::Auth.current_id = Card['john'].id
      Timecop.travel(Card.future_stamp)  # make sure we're ahead of all the test data
    end
  
    def expect_notice_for card_name
      expect_any_instance_of(Card::Set::Right::Account).to receive(:send_change_notice).with(kind_of(Card::Act), card_name)
    end
    
    it "sends notifications of edits" do
      expect_user("Sara").to be_notified_of "Sara Following"
      Card::Auth.current_id = Card['john'].id
      Card["Sara Following"].update_attributes :content => "A new change"
    end
  
    it "does not send notification to author of change" do
      expect_user("John").not_to receive(:send_change_notice)
      Card["All Eyes On Me"].update_attributes :content => "edit by John"
    end
  end
  
  context "when following cardtypes" do
    before do
      Card::Auth.current_id = Card['joe admin'].id
    end
    it "sends notifications of additions" do
      new_card = Card.new :name => "Microscope", :type => "Optic"
      expect_user("Sara").to be_notified_of "Optic"
      new_card.save!
    end

    it "sends notification of updates" do
      expect_user("Sara").to be_notified_of "Optic"
      Card["Sunglasses"].update_attributes :content => 'updated content'
    end
    
    it "sends only one notification per user"  do
      expect_user("Sara").to receive(:send_change_notice).exactly(1)
      Card["Google glass"].update_attributes :content => 'updated content'
    end
  end


  context "when following trunk" do
    before do
      Timecop.travel(Card.future_stamp)  # make sure we're ahead of all the test data
      Card::Auth.current_id = Card['joe user'].id
      Card.create :type=>'Book', :name=>'Ulysses'
      expect(Card['Ulysses']).to be
      Card.create :name=> 'joe camel+*following', :content=>'[[Ulysses]]'
      Card.create :name=> 'joe admin+*following', :content=>'[[Book]]'
    end

    it "sends notification to Joe Camel" do
      name = "Ulysses+author"
      expect_user("joe admin").to be_notified_of "Book"
      expect_user("joe camel").to be_notified_of "Ulysses"
      Card.create :name=>name, :content => "James Joyce"
    end
  end
end
