# -*- encoding : utf-8 -*-

class Card
  # An _action_ is a group of {Card::Change changes} to a single {Card card}
  # that is recorded during an {Card::Act act}.
  #
  # Card::Action records:
  # - the _card_id_ of the {Card card} acted upon
  # - the _card_act_id_ of the {Card::Act act} of which the action is part
  # - the _action_type_ (create, update, or delete)
  # - a boolean indicated whether the action is a _draft_
  # - a _comment_ (where applicable)
  #
  class Action < ActiveRecord::Base
    include Card::Action::Diff
    extend Card::Action::Admin

    belongs_to :act, foreign_key: :card_act_id, inverse_of: :actions
    has_many :card_changes, foreign_key: :card_action_id,
                            inverse_of: :action,
                            dependent: :delete_all,
                            class_name: "Card::Change"
    belongs_to :super_action, class_name: "Action", inverse_of: :sub_actions
    has_many :sub_actions, class_name: "Action", inverse_of: :super_action

    scope :created_by, lambda { |actor_id|
                         joins(:act).where "card_acts.actor_id = ?", actor_id
                       }

    enum action_type: [:create, :update, :delete]

    after_save :expire

    class << self
      def cache
        Card::Cache[Action]
      end

      def fetch id
        cache.fetch id.to_s do
          find id.to_i
        end
      end
    end

    def card
      Card.fetch card_id, look_in_trash: true, skip_modules: true
    end

    def expire
      self.class.cache.delete id.to_s
    end

    def value field
      return unless (change = change field)
      interpret_value field, change.value
    end

    def change field
      changes[interpret_field field]
    end

    def changes
      @changes ||=
        card_changes.each_with_object({}) do |change, hash|
          hash[change.field.to_sym] = change
        end
    end

    def previous_value field
      return if action_type == :create
      return unless (previous_change = previous_change field)
      interpret_value field, previous_change.value
    end

    def new_type?
      value :type_id
    end

    def new_content?
      value :db_content
    end

    def new_name?
      value :name
    end

    def revision_nr
      card.actions.index_of self
    end

    def previous_change field
      field = interpret_field field
      if @previous_changes && @previous_changes.key?(field)
        @previous_changes[field]
      else
        @previous_changes ||= {}
        @previous_changes[field] = card.last_change_on field, before: self
      end
    end

    def interpret_field field
      case field
      when :content then :db_content
      when :cardtype then :type_id
      else field.to_sym
      end
    end

    def interpret_value field, value
      case field.to_sym
      when :type_id
        value && value.to_i
      when :cardtype
        type_card = value && Card.quick_fetch(value.to_i)
        type_card && type_card.name.capitalize
      else value
      end
    end
  end
end
