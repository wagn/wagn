# -*- encoding : utf-8 -*-
module Wagn
  module Set::Right::Email
    extend Set

    format :base

    view  :raw, :right=>'email'  do |args|
      account = User[ card.left.id ]
      account ? account.send('email') : ''
    end
    view :raw, {:right=>'email'}, :core
  end
end
