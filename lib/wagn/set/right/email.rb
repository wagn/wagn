module Wagn::Set::Right::Email
  class Wagn::Views
    format :base

    define_view  :raw, :right=>'email'  do |args|
      account=User.where(:card_id=>card.left.id).first
      account ? account.send('email') : ''
    end
    alias_view :raw, {:right=>'email'}, :core
  end
end
