module PermissionTestHelper

  def assert_hidden_from( user, card, msg='')
    as(user) { assert_hidden( card, msg ) }
  end

  def assert_not_hidden_from( user, card, msg='')
    as(user) { assert_not_hidden( card, msg ) }
  end

  def assert_locked_from( user, card, msg='')
    as(user) { assert_locked( card, msg ) }
  end

  def assert_not_locked_from( user, card, msg='')
    as(user) { assert_not_locked( card, msg ) }
  end

  def assert_hidden( card, msg='' )
    assert_equal [], Card.search(:id=>card.id).plot(:name), msg
  end

  def assert_not_hidden( card, msg='' )
    assert_equal [card.name], Card.search(:id=>card.id).plot(:name), msg
  end

  def assert_locked( card, msg='' )
    assert_equal false, card.ok?(:update), msg
  end

  def assert_not_locked( card, msg='' )
    assert_equal true, card.ok?(:update), msg
  end
end
