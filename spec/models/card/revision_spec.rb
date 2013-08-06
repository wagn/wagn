# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card::Revision do

  it 'should be created whenever content is updated' do
    author1 = Account[ 'joe@user.com' ]
    author2 = Account[ 'sara@user.com' ]
    author_cd1 = Card[author1.card_id]
    author_cd2 = Card[author2.card_id]
    Account.current_id = Card::WagnBotID
    rc1=author_cd1.fetch(:new=>{}, :trait=>:roles)
    rc1 << Card::AdminID
    rc2 = author_cd2.fetch(:new=>{}, :trait=>:roles)
    rc2 << Card::AdminID
    author_cd1.save
    author_cd2.save
    Account.current_id = author_cd1.id
    card = Card.create! :name=>'alpha', :content=>'stuff'
    Account.current_id = author_cd2.id
    card.content = 'boogy'
    card.save
    card.reload

    assert_equal 2, card.revisions.count, 'Should have two revisions'
    assert_equal author_cd2.name, card.current_revision.creator.name, 'current author'
    assert_equal author_cd1.name, card.revisions.first.creator.name,  'first author'
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
    @user = Account[ Card['quentin'].id ]
    @card.content = "spot two"; @card.save
    @card.content = "spot three"; @card.save
    assert_equal 3, @card.revisions(true).length, "Should have three revisions"
    @card.current_revision(true)
    @card.rollback(0)
    assert_equal "some test content", @card.current_revision(true).content
  end
=end

end
