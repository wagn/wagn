# -*- encoding : utf-8 -*-

class Card
  # a Reference is a directional relationship from one card (the referer)
  # to another (the referee).
  class Reference < ActiveRecord::Base
    class << self
      # bulk insert improves performance considerably
      # array takes form [ [referer_id, referee_id, referee_key, ref_type], ...]
      def mass_insert array
        return if array.empty?
        value_statements = array.map { |values| "\n(#{values.join ', '})" }
        sql = "INSERT into card_references "\
              "(referer_id, referee_id, referee_key, ref_type) "\
              "VALUES #{value_statements.join ', '}"
        Card.connection.execute sql
      end

      # map existing reference to name to card via id
      def map_referees referee_key, referee_id
        where(referee_key: referee_key).update_all referee_id: referee_id
      end

      # references no longer refer to card, so remove id
      def unmap_referees referee_id
        where(referee_id: referee_id).update_all referee_id: nil
      end

      # find all references to missing (eg deleted) cards and reset them
      def unmap_if_referee_missing
        joins(
          "LEFT JOIN cards ON card_references.referee_id = cards.id"
        ).where(
          "(cards.id IS NULL OR cards.trash IS TRUE) AND referee_id IS NOT NULL"
        ).update_all referee_id: nil
      end

      # remove all references from missing (eg deleted) cards
      def delete_if_referer_missing
        joins(
          "LEFT JOIN cards ON card_references.referer_id = cards.id"
        ).where(
          "cards.id IS NULL"
        ).find_in_batches do |group|
          # used to be .delete_all here, but that was failing on large dbs
          puts "deleting batch of references"
          where("id in (#{group.map(&:id).join ','})").delete_all
        end
      end

      # repair references one by one (delete, create, delete, create...)
      # slower, but better than #repair_all for use on running sites
      def repair_all
        delete_if_referer_missing
        Card.where(trash: false).find_each do |card|
          Rails.logger.info "updating references from #{card}"
          card.include_set_modules
          card.update_references_out
        end
      end

      # delete all references, then recreate them one by one
      # faster than #repair_all, but not recommended for use on running sites
      def recreate_all
        delete_all
        Card.where(trash: false).find_each do |card|
          Rails.logger.info "updating references from #{card}"
          card.include_set_modules
          card.create_references_out
        end
      end
    end

    # card that refers
    def referer
      Card[referer_id]
    end

    # card that is referred to
    def referee
      Card[referee_id]
    end
  end
end
