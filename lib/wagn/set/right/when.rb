# -*- encoding : utf-8 -*-
module Wagn
  module Set::Right::When
    include Sets

    format :base

    define_view :raw, :right=>'when_created' do |args|
      card.left.new_card? ? '' : card.left.created_at.strftime('%A, %B %d, %Y %I:%M %p %Z')
    end

    alias_view :raw, {:right=>'when_created'}, :core

    define_view :raw, :right=>'when_last_edited' do |args|
      card.left.new_card? ? '' : card.left.updated_at.strftime('%A, %B %d, %Y %I:%M %p %Z')
    end

    alias_view :raw, {:right=>'when_last_edited'}, :core
  end
end
