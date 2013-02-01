# -*- encoding : utf-8 -*-
class Card::Revision < ActiveRecord::Base
  before_save :set_stamper

  def self.cache
    Wagn::Cache[Card::Revision]
  end

  def set_stamper
    self.creator_id = Account.user_id
  end

  def creator
    Card[ creator_id ]
  end

  def card
    Card[ card_id ]
  end

  def title #ENGLISH
    current_id = card.current_revision_id
    if id == current_id
      'Current Revision'
    elsif id > current_id
      'AutoSave'
    else
      card.revisions.each_with_index do |rev, index|
        return "Revision ##{index + 1}" if rev.id == id
      end
      '[Revisions Missing]'
    end
  end

end
