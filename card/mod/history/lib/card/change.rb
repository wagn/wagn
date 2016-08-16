# -*- encoding : utf-8 -*-
class Card
  class Change < ActiveRecord::Base
    belongs_to :action, foreign_key: :card_action_id, inverse_of: :card_changes

    class << self
      def delete_actionless
        joins(
          "LEFT JOIN card_actions "\
          "ON card_changes.card_action_id = card_actions.id "
        ).where(
          "card_actions.id is null"
        ).find_in_batches do |group|
          # used to be .delete_all here, but that was failing on large dbs
          puts "deleting batch of changes"
          where("id in (#{group.map(&:id).join ','})").delete_all
        end
      end

      def field_index value
        value.is_a?(Integer) ? value : TRACKED_FIELDS.index(value.to_s)
      end

      def find_by_field_name value
        find_by_field field_index(value)
      end
    end

    def field= value
      write_attribute(:field, TRACKED_FIELDS.index(value.to_s))
    end

    def field
      TRACKED_FIELDS[read_attribute(:field)]
    end

    def find_by_field_name value
      find_by_field self.class.field_index(value)
    end
  end
end
