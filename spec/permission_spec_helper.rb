module PermissionSpecHelper

  def assert_hidden_from( user, card, msg='')
    ::User.as(user) { assert_hidden( card, msg ) }
  end

  def assert_not_hidden_from( user, card, msg='')
    ::User.as(user) { assert_not_hidden( card, msg ) }
  end

  def assert_locked_from( user, card, msg='')
    ::User.as(user) { assert_locked( card, msg ) }
  end

  def assert_not_locked_from( user, card, msg='')
    ::User.as(user) { assert_not_locked( card, msg ) }
  end
  
  def assert_hidden( card, msg='' )
    assert_equal [], Card.search(:id=>card.id).plot(:name), msg  
  end
  
  def assert_not_hidden( card, msg='' )
    assert_equal [card.name], Card.search(:id=>card.id).plot(:name), msg
  end
  
  def assert_locked( card, msg='' )
    assert_equal false, card.ok?(:edit), msg
  end
  
  def assert_not_locked( card, msg='' )
    assert_equal true, card.ok?(:edit), msg
  end
end

ActiveSupport::TestCase.send :include, PermissionSpecHelper


class Card
  def writeable_by(user)
    ::User.as(user) do
      ok? :edit
    end
  end
    
  def readable_by(user)
    ::User.as(user) do
      ok? :read
    end
  end
    
  def appendable_by(user)
    ::User.as(user) do
      ok? :append
    end
  end 
end
 
