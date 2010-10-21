require File.dirname(__FILE__) + '/../test_helper'
class RevisionTest < ActiveSupport::TestCase
  
  def setup
    setup_default_user
  end
  
  def test_revise
    author1 = User.find_by_email('joe@user.com')
    author2 = User.find_by_email('sara@user.com')
    #author1, author2 = User.find(:all, :limit=>2)
    User.current_user = author1
    author1.roles << Role.find_by_codename('admin')
    author2.roles << Role.find_by_codename('admin')
    card = newcard( 'alpha', 'stuff')
    User.current_user = author2
    card.content = 'boogy'
    card.save
    card.reload
    
    assert_equal 2, card.revisions.length, 'Should have two revisions'
    assert_equal author2.card.name, card.current_revision.author.card.name, 'current author'
    assert_equal author1.card.name, card.revisions.first.author.card.name,  'first author'
  end

=begin 
  # FIXME- should revisit what we want to have happen here; for now keep saving unchanged revisions..
  def test_revise_content_unchanged
    @card = newcard('alpha', 'banana')
    last_revision_before = @card.current_revision
    revisions_number_before = @card.revisions.size
  
    @card.content = (@card.current_revision.content)
    @card.save

    assert_equal last_revision_before, @card.current_revision(true)
    assert_equal revisions_number_before, @card.revisions.size
  end
=end  

=begin #FIXME - don't think this is used by any controller. we'll see what breaks
  def test_rollback
    @card = newcard("alhpa", "some test content")
    @user = User.find_by_login('quentin')
    @card.content = "spot two"; @card.save
    @card.content = "spot three"; @card.save
    assert_equal 3, @card.revisions(true).length, "Should have three revisions"
    @card.current_revision(true)
    @card.rollback(0)
    assert_equal "some test content", @card.current_revision(true).content
  end
=end

  def test_save_draft
    @card = newcard("mango", "foo")
    @card.save_draft("bar")
    assert_equal 1, @card.drafts.length
    @card.save_draft("booboo")
    assert_equal 1, @card.drafts.length
    assert_equal "booboo", @card.drafts[0].content
  end
  
end
