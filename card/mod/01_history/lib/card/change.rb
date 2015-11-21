# -*- encoding : utf-8 -*-
class Card
  class Change < ActiveRecord::Base
    belongs_to :action, foreign_key: :card_action_id, inverse_of: :card_changes

    def field=(value)
      write_attribute(:field, Card::TRACKED_FIELDS.index(value.to_s))
    end

    def field
      Card::TRACKED_FIELDS[read_attribute(:field)]
    end

    def self.delete_actionless
      Card::Change.where(
        "card_action_id NOT IN (?)",
        Card::Action.pluck("id"),
      ).delete_all
    end

    def find_by_field_name(value)
      index = value.is_a?(Integer) ? value : Card::TRACKED_FIELDS.index(value.to_s)
      find_by_field(index)
    end

    def self.find_by_field_name(value)
      index = value.is_a?(Integer) ? value : Card::TRACKED_FIELDS.index(value.to_s)
      find_by_field(index)
    end
  end
end


