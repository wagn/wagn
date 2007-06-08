require File.dirname(__FILE__) + '/../test_helper'
class RevisionTest < Test::Unit::TestCase
  common_fixtures
  def setup
    setup_default_user
  end
  
  def test_revise
    author1, author2 = User.find(:all, :limit=>2)
    User.current_user = author1
    author1.roles << Role.find_by_codename('admin')
    author2.roles << Role.find_by_codename('admin')
    card = newcard( 'alpha', 'stuff')
    User.current_user = author2
    card.revise('boogy')
    card.reload
    
    assert_equal 2, card.revisions.length, 'Should have two revisions'
    assert_equal author2.card.name, card.current_revision.author.card.name, 'current author'
    assert_equal author1.card.name, card.revisions.first.author.card.name,  'first author'
  end

  def test_revise_content_unchanged
    @card = newcard('alpha', 'banana')
    last_revision_before = @card.current_revision
    revisions_number_before = @card.revisions.size
  
    assert_raises(Wagn::Oops) { 
      @card.revise(@card.current_revision.content)
    }
    assert_equal last_revision_before, @card.current_revision(true)
    assert_equal revisions_number_before, @card.revisions.size
  end

  def test_rollback
    @card = newcard("alhpa", "some test content")
    @user = User.find_by_login('quentin')
    @card.revise("spot two")
    @card.revise("spot three")
    assert_equal 3, @card.revisions(true).length, "Should have three revisions"
    @card.current_revision(true)
    @card.rollback(0)
    assert_equal "some test content", @card.current_revision(true).content
  end

  def test_save_draft
    @card = newcard("mango", "foo")
    @card.save_draft("bar")
    assert_equal 1, @card.drafts.length
    @card.save_draft("booboo")
    assert_equal 1, @card.drafts.length
    assert_equal "booboo", @card.drafts[0].content
  end
  
end
