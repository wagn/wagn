# -*- encoding : utf-8 -*-

class Card
  # a Reference is a directional relationship from one card to another.
  class Reference < ActiveRecord::Base
    class << self
      # bulk insert improves performance considerably
      # array takes form [ [referer_id, referee_id, referee_key, ref_type], ...]
      def mass_insert array
        return if array.empty?
        value_statements = array.map { |values| "\n(#{values.join ', '})" }
        sql = 'INSERT into card_references '\
              '(referer_id, referee_id, referee_key, ref_type) '\
              "VALUES #{value_statements.join ', '}"
        Card.connection.execute sql
      end

      def reset_referee referee_id
        where(referee_id: referee_id).update_all referee_id: nil
      end

      def reset_referee_if_missing
        joins(
          'LEFT JOIN cards ON card_references.referee_id = cards.id'
        ).where(
          '(cards.id IS NULL OR cards.trash IS TRUE) AND referee_id IS NOT NULL'
        ).update_all referee_id: nil
      end

      def update_referee_key_with_id referee_key, referee_id
        where(referee_key: referee_key).update_all referee_id: referee_id
      end

      def update_on_rename card, newname, update_referers=false
        if update_referers
          # not currently needed because references are deleted and re-created
          # in the process of adding new revision
        else
          reset_referee card.id
        end
        update_referee_key_with_id newname.to_name.key, card.id
      end

      def delete_referer_if_missing
        joins(
          'LEFT JOIN cards ON card_references.referer_id = cards.id'
        ).where(
          'cards.id IS NULL'
        ).find_in_batches do |group|
          # used to be .delete_all here, but that was failing on large dbs
          puts 'deleting batch of references'
          where("id in (#{group.map(&:id).join ','})").delete_all
        end
      end

      def repair_all
        delete_referer_if_missing
        Card.where(trash: false).find_each do |card|
          Rails.logger.info "updating references from #{card}"
          card.include_set_modules
          card.update_references_out
        end
      end
    end

    def referer
      Card[referer_id]
    end

    def referee
      Card[referee_id]
    end
  end
end
