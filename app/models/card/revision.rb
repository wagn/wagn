# -*- encoding : utf-8 -*-
class Card::Revision < ActiveRecord::Base
  belongs_to :card, :class_name=>"Card", :foreign_key=>'card_id'
  
  cattr_accessor :cache
  stampable :stamper_class_name => :card
  
  def author
    c=Card[creator_id]
    #warn "author #{creator_id}, #{c}, #{self}"; c
  end
  
  
  def title
    current_id = card.cached_revision.id
    if id == current_id
      'Current Revision'
    elsif id > current_id
      'AutoSave'
    else
      card.revisions.each_with_index do |rev, index|
        return "Revision ##{index + 1}"  if rev.id == id
      end
    end
  end
  
end
