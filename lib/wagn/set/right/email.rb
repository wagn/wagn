module Wagn
  module Set
    module Right::Email
      include Sets

      format :base

      define_view  :raw, :right=>'email'  do |args|
        account=User.where(:card_id=>card.left.id).first
        account ? account.send('email') : ''
      end
      alias_view :raw, {:right=>'email'}, :core
    end
  end
end
