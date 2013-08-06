# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card do

  describe "test data" do
    it "should be findable by name" do
      Card["Wagn Bot"].class.should == Card
    end
  end

  describe "creation" do
    before(:each) do
      Account.as_bot do
        @b = Card.create! :name=>"New Card", :content=>"Great Content"
        @c = Card.find(@b.id)
      end
    end

    it "should not have errors"        do @b.errors.size.should == 0        end
    it "should have the right class"   do @c.class.should    == Card        end
    it "should have the right key"     do @c.key.should      == "new_card"  end
    it "should have the right name"    do @c.name.should     == "New Card"  end
    it "should have the right content" do @c.content.should  == "Great Content" end

    it "should have a revision with the right content" do
      @c.current_revision.content == "Great Content"
    end

    it "should be findable by name" do
      Card["New Card"].class.should == Card
    end
  end


  describe "content change should create new revision" do
    before do
      Account.as_bot do
        @c = Card['basicname']
        @c.update_attributes! :content=>'foo'
      end
    end

    it "should have 2 revisions"  do
      @c.revisions.length.should == 2
    end

    it "should have original revision" do
      @c.revisions[0].content.should == 'basiccontent'
    end
  end



  describe "created a virtual card when missing and has a template" do
    it "should be flagged as virtual" do
      Card.new(:name=>'A+*last edited').virtual?.should be_true
    end
  end
end

describe "basic card tests" do


  def assert_simple_card card
    card.name.should be, "name not null"
    card.name.empty?.should be_false, "name not empty"
    rev = card.current_revision
    rev.should be_instance_of Card::Revision
    rev.creator.should be_instance_of Card
  end

  def assert_samecard card1, card2
    assert_equal card1.current_revision, card2.current_revision
  end

  def assert_stable card1
    card2 = Card[card1.name]
    assert_simple_card card1
    assert_simple_card card2
    assert_samecard card1, card2
    assert_equal card1.right, card2.right
  end

  it 'should remove cards' do
    forba = Card.create! :name=>"Forba"
    torga = Card.create! :name=>"TorgA"
    torgb = Card.create! :name=>"TorgB"
    torgc = Card.create! :name=>"TorgC"

    forba_torga = Card.create! :name=>"Forba+TorgA";
    torgb_forba = Card.create! :name=>"TorgB+Forba";
    forba_torga_torgc = Card.create! :name=>"Forba+TorgA+TorgC";

    Card['Forba'].delete!

    Card["Forba"].should be_nil
    Card["Forba+TorgA"].should be_nil
    Card["TorgB+Forba"].should be_nil
    Card["Forba+TorgA+TorgC"].should be_nil

    # FIXME: this is a pretty dumb test and it takes a loooooooong time
    #while card = Card.find(:first,:conditions=>["type not in (?,?,?) and trash=?", 'AccountRequest','User','Cardtype',false] )
    #  card.delete!
    #end
    #assert_equal 0, Card.find_all_by_trash(false).size
  end

  #test test_attribute_card
  #  alpha, beta = Card.create(:name=>'alpha'), Card.create(:name=>'beta')
  #  assert_nil alpha.attribute_card('beta')
  #  Card.create :name=>'alpha+beta'
  #   alpha.attribute_card('beta').should be_instance_of(Card)
  #end

  it 'should create cards' do
    alpha = Card.new :name=>'alpha', :content=>'alpha'
    alpha.content.should == 'alpha'
    alpha.save
    alpha.name.should == 'alpha'
    assert_stable alpha
  end


  it 'should not find nonexistent' do
    Card['no such card+no such tag'].should be_nil
    Card['HomeCard+no such tag'].should be_nil
  end


  it 'update_should_create_subcards' do
    banana = Card.create! :name=>'Banana'
    Card.update banana.id, :cards=>{ "+peel" => { :content => "yellow" }}

    peel = Card['Banana+peel']
    peel.content.       should == "yellow"
    Card['joe_user'].id.should == peel.creator_id
  end

  it 'update_should_create_subcards_as_wagn_bot_if_missing_subcard_permissions' do
    Card.create :name=>'peel'
    Account.current_id = Card::AnonID
    Card['Banana'].should_not be
    Card['Basic'].ok?(:create).should be_false, "anon can't creat"

    Card.create! :type=>"Fruit", :name=>'Banana', :cards=>{ "+peel" => { :content => "yellow" }}
    Card['Banana'].should be
    peel = Card["Banana+peel"]

    peel.current_revision.content.should == "yellow"
    peel.creator_id.should == Card::AnonID
  end

  it 'update_should_not_create_subcards_if_missing_main_card_permissions' do
    b = Card.create!( :name=>'Banana' )
    Account.as Card::AnonID do
      assert_raises( Card::PermissionDenied ) do
        Card.update(b.id, :cards=>{ "+peel" => { :content => "yellow" }})
      end
    end
  end


  it 'create_without_read_permission' do
    c = Card.create!({:name=>"Banana", :type=>"Fruit", :content=>"mush"})
    Account.as Card::AnonID do
      assert_raises Card::PermissionDenied do
        c.ok! :read
      end
    end
  end

end
