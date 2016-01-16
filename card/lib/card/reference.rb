# -*- encoding : utf-8 -*-

class Card::Reference < ActiveRecord::Base
  def referencer
    Card[referer_id]
  end

  def referencee
    Card[referee_id]
  end

  class << self
    def delete_all_from card
      delete_all referer_id: card.id
    end

    def delete_all_to card
      where(referee_id: card.id).update_all present: 0, referee_id: nil
    end

    def update_existing_key card, name=nil
      key = (name || card.name).to_name.key
      where(referee_key: key).update_all present: 1, referee_id: card.id
    end

    def update_on_rename card, newname, update_referers=false
      if update_referers
        # not currently needed because references are deleted and re-created
        # in the process of adding new revision
        # where referee_id: card.id).update_all referee_key: newname.to_name.key
      else
        delete_all_to card
      end
      update_existing_key card, newname
    end

    def update_on_delete card
      delete_all_from card
      delete_all_to card
    end

    def repair_missing_referees
      joins(
        'LEFT JOIN cards ON card_references.referee_id = cards.id'
      ).where(
        '(cards.id IS NULL OR cards.trash IS TRUE) AND referee_id IS NOT NULL'
      ).update_all referee_id: nil
    end

    def delete_missing_referers
      joins(
        'LEFT JOIN cards ON card_references.referer_id = cards.id'
      ).where(
        'cards.id IS NULL OR cards.trash IS TRUE'
      ).delete_all
    end

    def repair_all
      delete_missing_referers

      Card.where(trash: false).find_each do |card|
        Rails.logger.info "Repairing references for '#{card.name}'" \
                          "(id: #{card.id}) ... "
        card.update_references
      end
    end
  end
end
