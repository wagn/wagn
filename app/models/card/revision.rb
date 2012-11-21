# -*- encoding : utf-8 -*-
class Card::Revision < ActiveRecord::Base
  belongs_to :card, :class_name=>"Card", :foreign_key=>'card_id'

  cattr_accessor :cache

  belongs_to :card, :class_name => 'Card', :foreign_key => :creator_id

  before_save :set_stamper

  def set_stamper
    self.creator_id = Session.user_id
  end

  def author
    Card[ creator_id ]
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
