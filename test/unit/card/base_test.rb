require File.expand_path('../../test_helper', File.dirname(__FILE__))
class Card::BaseTest < ActiveSupport::TestCase

  def setup
    super
    setup_default_user
  end

  test 'remove' do
    forba = Card.create! :name=>"Forba"
    torga = Card.create! :name=>"TorgA"
    torgb = Card.create! :name=>"TorgB"
    torgc = Card.create! :name=>"TorgC"

    forba_torga = Card.create! :name=>"Forba+TorgA";
    torgb_forba = Card.create! :name=>"TorgB+Forba";
    forba_torga_torgc = Card.create! :name=>"Forba+TorgA+TorgC";

    forba.reload #hmmm
    Card['Forba'].destroy!
    assert_nil Card["Forba"]
    assert_nil Card["Forba+TorgA"]
    assert_nil Card["TorgB+Forba"]
    assert_nil Card["Forba+TorgA+TorgC"]

    # FIXME: this is a pretty dumb test and it takes a loooooooong time
    #while card = Card.find(:first,:conditions=>["type not in (?,?,?) and trash=?", 'AccountRequest','User','Cardtype',false] )
    #  card.destroy!
    #end
    #assert_equal 0, Card.find_all_by_trash(false).size
  end

  #test test_attribute_card
  #  alpha, beta = Card.create(:name=>'alpha'), Card.create(:name=>'beta')
  #  assert_nil alpha.attribute_card('beta')
  #  Card.create :name=>'alpha+beta'
  #  assert_instance_of Card, alpha.attribute_card('beta')
  #end

  test 'create' do
    alpha = Card.new :name=>'alpha', :content=>'alpha'
    assert_equal 'alpha', alpha.content
    #warn "About to save #{alpha.inspect}"
    alpha.save
    assert alpha.name
    assert_stable(alpha)
  end


  # just a sanity check that we don't have broken data to start with
  test 'fixtures' do
    Card.find(:all).each do |p|
      assert_instance_of String, p.name
    end
  end

  test 'find_by_name' do
    card = Card.create( :name=>"ThisMyCard", :content=>"Contentification is cool" )
    assert_equal card, Card["ThisMyCard"]
  end


  test 'find_nonexistent' do
    assert !Card['no such card+no such tag']
    assert !Card['HomeCard+no such tag']
  end


  test 'update_should_create_subcards' do
    Session.user = 'joe_user'
    Session.as(:joe_user) do
      c=Card.create!( :name=>'Banana' )
      #warn "created #{c.inspect}"
      Card.update(c.id, :cards=>{ "+peel" => { :content => "yellow" }})
      p = Card['Banana+peel']
      assert_equal "yellow", p.content
      #warn "creator_id #{p.creator_id}, #{p.updater_id}, #{p.created_at}"
      assert_equal Card['joe_user'].id, p.creator_id
    end
  end

  test 'update_should_create_subcards_as_wagn_bot_if_missing_subcard_permissions' do
    Card.create(:name=>'peel')
    Session.user = :anonymous
    #warn Rails.logger.info("check #{Session.user_id}")
    assert_equal false, Card['Basic'].ok?(:create), "anon can't creat"
    Card.create!( :type=>"Fruit", :name=>'Banana', :cards=>{ "+peel" => { :content => "yellow" }})
    peel= Card["Banana+peel"]
    #warn "peel #{peel.creator_id}, #{peel.updater_id}, #{peel.created_at}"
    assert_equal "yellow", peel.current_revision.content
    assert_equal Card::AnonID, peel.creator_id
  end

  test 'update_should_not_create_subcards_if_missing_main_card_permissions' do
    b = nil
    Session.as(:joe_user) do
      b = Card.create!( :name=>'Banana' )
      #warn "created #{b.inspect}"
    end
    Session.as Card::AnonID do
      assert_raises( Card::PermissionDenied ) do
        Card.update(b.id, :cards=>{ "+peel" => { :content => "yellow" }})
      end
    end
  end


  test 'create_without_read_permission' do
    c = Card.create!({:name=>"Banana", :type=>"Fruit", :content=>"mush"})
    Session.as Card::AnonID do
      assert_raises Card::PermissionDenied do
        c.ok! :read
      end
    end
  end


  private

  def assert_simple_card( card )
    assert !card.name.nil?, "name not null"
    assert !card.name.empty?, "name not empty"
    rev = card.current_revision
    assert_instance_of Card::Revision, rev
    #warn "revision #{rev.inspect}, #{rev.author}"
    assert_instance_of Card, rev.author
  end

  def assert_samecard( card1, card2 )
    assert_equal card1.current_revision, card2.current_revision
    assert_equal card1.right, card2.right
  end

  def assert_stable( card1 )
    card2 = Card[card1.name]
    assert_simple_card( card1 )
    assert_simple_card( card2 )
    assert_samecard( card1, card2 )
  end
end

