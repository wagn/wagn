require File.dirname(__FILE__) + '/../test_helper'
class TagTest < Test::Unit::TestCase
  common_fixtures
  def setup
    setup_default_user
  end
  
  def test_create
    t = Tag.new( :name=> 'TagOne' )
    assert_equal 'TagOne', t.name
    assert t.save
    t = Tag.find(t.id)
    assert_equal t.name, 'TagOne'
  end
    
  def test_rename
    t1 = Tag.create( :name=>'alpha' )
    assert_equal 1, t1.revisions.length
    t1.rename( 'beta' )
    assert_equal t1.name, 'beta'
    t1.reload
    assert_equal 2, t1.revisions.length
    assert_equal t1.name, 'beta'
  end
  
  def test_recent_revisions
    t1 = Tag.create( :name=>'alpha' )
    #assert_equal 1, t1.revisions.length
    t1.rename( 'beta' )
    t1.rename( 'delta' )
    t1.reload
    assert_equal 2, t1.recent_revisions('7 day').length 
    #assert_equal t1.name, 'beta'
    #t1.reload
    #assert_equal 2, t1.revisions.length
    #assert_equal t1.name, 'beta'
  end

  def test_card_count
    card1 = newcard "ThisMyCard1", "Contentification is cool"
    card2 = newcard "ThisMyCard2", "Contentification is cool"
    card3 = newcard "ThisMyCard3", "Contentification is cool"
    
    tag = Card::Basic.create(:name=>"TaggingCard1",:content=>"cool").tag
    assert_equal 0, tag.reload.card_count; connection1 = card1.add_tag( tag )
    assert_equal 1, tag.reload.card_count; connection2 = card2.add_tag( tag )
    assert_equal 2, tag.reload.card_count; connection1.destroy
    assert_equal 1, tag.reload.card_count; connection2.destroy
    assert_equal 0, tag.reload.card_count; tag.root_card.destroy    
  end
  
end
