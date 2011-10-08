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
    assert_nil Card.find_by_name("Forba")
    assert_nil Card.find_by_name("Forba+TorgA")
    assert_nil Card.find_by_name("TorgB+Forba")
    assert_nil Card.find_by_name("Forba+TorgA+TorgC")
    
    # FIXME: this is a pretty dumb test and it takes a loooooooong time
    #while card = Card.find(:first,:conditions=>["type not in (?,?,?) and trash=?", 'InvitationRequest','User','Cardtype',false] )
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
    assert_equal card, Card.find_by_name("ThisMyCard")
  end
 
  
  test 'find_nonexistent' do
    assert !Card.find_by_name('no such card+no such tag')
    assert !Card.find_by_name('HomeCard+no such tag')
  end
          

  test 'update_should_create_subcards' do
    User.current_user = :joe_user
    User.as(:joe_user) do
      b = Card.create!( :name=>'Banana' )
      Card.update(b.id, :cards=>{ "+peel" => { :content => "yellow" }})
      assert_equal "yellow", Card["Banana+peel"].content   
      assert_equal User[:joe_user].id, Card["Banana+peel"].created_by
    end
  end
  
  test 'update_should_create_subcards_as_wagbot_if_missing_subcard_permissions' do
    Card.create(:name=>'peel')
    User.current_user = :anon
    assert_equal false, Card.fetch('Basic').ok?(:create)
    Card.create!( :type=>"Fruit", :name=>'Banana', :cards=>{ "+peel" => { :content => "yellow" }})
    assert_equal "yellow", Card["Banana+peel"].current_revision.content
    assert_equal User[:anon].id, Card["Banana+peel"].created_by
  end

  test 'update_should_not_create_subcards_if_missing_main_card_permissions' do
    b = nil
    User.as(:joe_user) do
      b = Card.create!( :name=>'Banana' )
    end
    User.as(:anon) do
      assert_raises( Card::PermissionDenied ) do
        Card.update(b.id, :cards=>{ "+peel" => { :content => "yellow" }})
      end
    end
  end


  test 'create_without_read_permission' do
    c = Card.create! :name=>"Banana", :type=>"Fruit", :content=>"mush"
    User.as(:anon) do
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
    assert_instance_of Revision, rev
    assert_instance_of User, rev.author
  end
  
  def assert_samecard( card1, card2 )
    assert_equal card1.current_revision, card2.current_revision
    assert_equal card1.tag, card2.tag
  end
 
  def assert_stable( card1 )
    card2 = Card.find_by_name(card1.name)
    assert_simple_card( card1 )
    assert_simple_card( card2 )
    assert_samecard( card1, card2 )
  end
end

