module PermissionSpecHelper

  def assert_hidden_from( user, card, msg='')
    Account.as(user.id) { assert_hidden( card, msg ) }
  end

  def assert_not_hidden_from( user, card, msg='')
    Account.as(user.id) { assert_not_hidden( card, msg ) }
  end

  def assert_locked_from( user, card, msg='')
    Account.as(user.id) { assert_locked( card, msg ) }
  end

  def assert_not_locked_from( user, card, msg='')
    Account.as(user.id) { assert_not_locked( card, msg ) }
  end

  def assert_hidden( card, msg='' )
    assert_equal [], Card.search(:id=>card.id).map(&:name), msg
  end

  def assert_not_hidden( card, msg='' )
    assert_equal [card.name], Card.search(:id=>card.id).map(&:name), msg
  end

  def assert_locked( card, msg='' )
    assert_equal false, card.ok?(:update), msg
  end

  def assert_not_locked( card, msg='' )
    assert_equal true, card.ok?(:update), msg
  end
end

RSpec::Core::ExampleGroup.send :include, PermissionSpecHelper


class Card
  def writeable_by(user)
    Account.as(user.id) do
    #warn "writeable #{Account.as_id}, #{user.inspect}"
      ok? :update
    end
  end

  def readable_by(user)
    Account.as(user.id) do
      ok? :read
    end
  end

  def appendable_by(user)
    Account.as(user.id) do
      ok? :append
    end
  end
end

