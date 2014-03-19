# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card::Revision do

  it 'should be created whenever content is updated' do
    author1 = Card::Auth[ 'joe@user.com' ]
    author2 = Card::Auth[ 'sara@user.com' ]
    author_cd1 = Card[author1.id]
    author_cd2 = Card[author2.id]
    Card::Auth.current_id = Card::WagnBotID
    rc1=author_cd1.fetch(:new=>{}, :trait=>:roles)
    rc1 << Card::AdminID
    rc2 = author_cd2.fetch(:new=>{}, :trait=>:roles)
    rc2 << Card::AdminID
    author_cd1.save
    author_cd2.save
    Card::Auth.current_id = author_cd1.id
    card = Card.create! :name=>'alpha', :content=>'stuff'
    Card::Auth.current_id = author_cd2.id
    card.content = 'boogy'
    card.save
    card.reload

    assert_equal 2, card.revisions.count, 'Should have two revisions'
    assert_equal author_cd2.name, card.current_revision.creator.name, 'current author'
    assert_equal author_cd1.name, card.revisions.first.creator.name,  'first author'
  end


end
