# -*- encoding : utf-8 -*-

class Card
  class Action < ActiveRecord::Base
    belongs_to :act,  foreign_key: :card_act_id, inverse_of: :actions
    has_many :card_changes, foreign_key: :card_action_id, inverse_of: :action,
                            dependent: :delete_all, class_name: "Card::Change"

    belongs_to :super_action, class_name: "Action", inverse_of: :sub_actions
    has_many :sub_actions, class_name: "Action", inverse_of: :super_action

    scope :created_by, lambda { |actor_id|
                         joins(:act).where "card_acts.actor_id = ?", actor_id
                       }

    # replace with enum if we start using rails 4
    TYPE = [:create, :update, :delete].freeze

    def expire
      self.class.cache.delete id.to_s
    end

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

      def delete_cardless
        left_join = "LEFT JOIN cards ON card_actions.card_id = cards.id"
        joins(left_join).where("cards.id IS NULL").delete_all
      end

      def delete_changeless
        joins(
          "LEFT JOIN card_changes "\
          "ON card_changes.card_action_id = card_actions.id"
        ).where(
          "card_changes.id IS NULL"
        ).delete_all
      end

      def delete_old
        Card.find_each(&:delete_old_actions)
        Card::Act.delete_actionless
      end
    end

    #
    # This is the main API from Cards to history
    # See also create_act_and_action, which needs to happen before this or we
    # don't have the action to call this method on.
    #
    # When changes are stored for versioned attributes, this is the signal
    # method. By overriding this method in a module, the module takes over
    # handling of changes.  Although the standard version stores the Changes in
    # ActiveRecord models (Act, Action and Change records), these could be
    # /dev/nulled for a history-less implementation, or handled by an external
    # service.
    #
    # If change streams are generated from database triggers, and we aren't
    # writing here (disabled history), we still have to generate change stream
    # events in another way.

    # def changed_fields obj, changed_fields
    #   changed_fields.each do |f|
    #     Card::Change.create field: f, value: obj[f], card_action_id: id
    #   end
    # end

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

    def action_type= value
      write_attribute :action_type, TYPE.index(value)
    end

    def action_type
      TYPE[read_attribute(:action_type)]
    end

    def revision_nr
      card.actions.index_of self
    end

    def red?
      content_diff_object.red?
    end

    def green?
      content_diff_object.green?
    end

    def name_diff opts={}
      return unless new_name?
      Card::Diff.complete previous_value(:name), value(:name), opts
    end

    def cardtype_diff opts={}
      return unless new_type?
      Card::Diff.complete previous_value(:cardtype), value(:cardtype), opts
    end

    def content_diff diff_type=:expanded, opts=nil
      return unless new_content?
      if diff_type == :summary
        content_diff_object(opts).summary
      else
        content_diff_object(opts).complete
      end
    end

    def card
      Card.fetch card_id, look_in_trash: true, skip_modules: true
    end

    private

    def content_diff_object opts=nil
      @diff ||= begin
        diff_args = opts || card.include_set_modules.diff_args
        Card::Diff.new previous_value(:content), value(:content), diff_args
      end
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
