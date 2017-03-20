# -*- encoding : utf-8 -*-
class Card
  # A _change_ is an alteration to a card's name, type, content, or trash state.
  # Together, {Act acts}, {Action actions}, and {Change changes} comprise a
  # comprehensive {Card card} history tracking system.
  #
  # For example, if a given web submission changes both the name and type of
  # card, that would be recorded as one {Action action} with two
  # {Change changes}.
  #
  # A {Change} records:
  #
  # * the _field_ changed
  # * the new _value_ of that field
  # * the {Action action} of which the change is part
  #
  class Change < ActiveRecord::Base
    belongs_to :action, foreign_key: :card_action_id,
                        inverse_of: :card_changes

    # lists the database fields for which changes are recorded
    TRACKED_FIELDS = %w(name type_id db_content trash).freeze

    class << self
      # delete all {Change changes} not associated with an {Action action}
      # (janitorial)
      def delete_actionless
        joins(
          "LEFT JOIN card_actions "\
          "ON card_changes.card_action_id = card_actions.id "
        ).where(
          "card_actions.id is null"
        ).pluck_in_batches(:id) do |group_ids|
          # used to be .delete_all here, but that was failing on large dbs
          puts "deleting batch of changes"
          where("id in (#{group_ids.join ','})").delete_all
        end
      end

      # Change fields are recorded as integers. #field_index looks up the
      # integer associated with a given field name.
      # @param value [String, Symbol]
      # @return [Integer]
      def field_index value
        value.is_a?(Integer) ? value : TRACKED_FIELDS.index(value.to_s)
      end

      # look up changes based on field name
      # @param value [String, Symbol]
      # @return [Change]
      def find_by_field_name value
        find_by_field field_index(value)
      end
    end

    # set field value (integer)
    # @param value [String, Symbol]
    def field= value
      write_attribute(:field, TRACKED_FIELDS.index(value.to_s))
    end

    # retrieve field name
    # @return [String]
    def field
      TRACKED_FIELDS[read_attribute(:field)]
    end
  end
end
