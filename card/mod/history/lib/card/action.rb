# -*- encoding : utf-8 -*-

class Card
  # An _action_ is a group of {Card::Change changes} to a single {Card card}
  # that is recorded during an {Card::Act act}.
  # Together, {Act acts}, {Action actions}, and {Change changes} comprise a
  # comprehensive {Card card} history tracking system.
  #
  # For example, if a given web submission changes both the name and type of
  # a given card, that would be recorded as one {Action action} with two
  # {Change changes}. If there are multiple cards changed, each card would
  # have its own {Action action}, but the whole submission would still comprise
  # just one single {Act act}.
  #
  # An {Action} records:
  #
  # * the _card_id_ of the {Card card} acted upon
  # *  the _card_act_id_ of the {Card::Act act} of which the action is part
  # * the _action_type_ (create, update, or delete)
  # * a boolean indicated whether the action is a _draft_
  # * a _comment_ (where applicable)
  #
  class Action < ActiveRecord::Base
    include Card::Action::Differ
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

    # these are the three possible values for action_type
    TYPE_OPTIONS = %i[create update delete].freeze

    after_save :expire

    class << self
      # retrieve action from cache if available
      # @param id [id of Action]
      # @return [Action, nil]
      def fetch id
        cache.fetch id.to_s do
          find id.to_i
        end
      end

      # cache object for actions
      # @return [Card::Cache]
      def cache
        Card::Cache[Action]
      end
    end

    # each action is associated with on and only one card
    # @return [Card]
    def card
      res = Card.fetch card_id, look_in_trash: true, skip_modules: true
      return res unless res && res.type_id.in?([FileID, ImageID])
      res.include_set_modules
    end

    # remove action from action cache
    def expire
      self.class.cache.delete id.to_s
    end

    # assign action_type (create, update, or delete)
    # @param value [Symbol]
    # @return [Integer]
    def action_type= value
      write_attribute :action_type, TYPE_OPTIONS.index(value)
    end

    # retrieve action_type (create, update, or delete)
    # @return [Symbol]
    def action_type
      return :draft if draft
      TYPE_OPTIONS[read_attribute(:action_type)]
    end

    # value set by action's {Change} to given field
    # @see #interpret_field #interpret_field for field param
    # @see #interpret_value #interpret_value for return values
    def value field
      return unless (change = change field)
      interpret_value field, change.value
    end

    # value of field set by most recent {Change} before this one
    # @see #interpret_field #interpret_field for field param
    # @see #interpret_field  #interpret_field for field param
    def previous_value field
      return if action_type == :create
      return unless (previous_change = previous_change field)
      interpret_value field, previous_change.value
    end

    # action's {Change} object for given field
    # @see #interpret_field #interpret_field for field param
    # @return [Change]
    def change field
      changes[interpret_field field]
    end

    # most recent change to given field before this one
    # @see #interpret_field #interpret_field for field param
    # @return [Change]
    def previous_change field
      field = interpret_field field
      if @previous_changes && @previous_changes.key?(field)
        @previous_changes[field]
      else
        @previous_changes ||= {}
        @previous_changes[field] = card.last_change_on field, before: self
      end
    end

    # all action {Change changes} in hash form. { field1: Change1 }
    # @return [Hash]
    def changes
      @changes ||=
        card_changes.each_with_object({}) do |change, hash|
          hash[change.field.to_sym] = change
        end
    end

    # does action change card's type?
    # @return [true/false]
    def new_type?
      !value(:type_id).nil?
    end

    # does action change card's content?
    # @return [true/false]
    def new_content?
      !value(:db_content).nil?
    end

    # does action change card's name?
    # @return [true/false]
    def new_name?
      !value(:name).nil?
    end

    # translate field into fieldname as referred to in database
    # @see Change::TRACKED_FIELDS
    # @param field [Symbol] can be :type_id, :cardtype, :db_content, :content,
    #     :name, :trash
    # @return [Symbol]
    def interpret_field field
      case field
      when :content then :db_content
      when :cardtype then :type_id
      else field.to_sym
      end
    end

    # value in form prescribed for specific field name
    # @param value [value of {Change}]
    # @return [Integer] for :type_id
    # @return [String] for :name, :db_content, :content, :cardtype
    # @return [True/False] for :trash
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
