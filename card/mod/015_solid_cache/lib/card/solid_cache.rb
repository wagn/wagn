# -*- encoding : utf-8 -*-

def self.included host_class
  host_class.extend ClassMethods
  host_class.card_writer :solid_cache, type: :plain_text
  host_class
end

def cached_content
  solid_cached_count_card.content.to_i
end

def self.pointer_card_changed_card_names card
  return card.item_names if card.trash
  old_changed_card_content = card.last_action.previous_value(:content)
  old_card = Card.new type_id: PointerID, content: old_changed_card_content
  (old_card.item_names - card.item_names) +
    (card.item_names - old_card.item_names)
end

module ClassMethods
  def cache_expire_trigger

  end

  # If a card of the set given by 'set_of_changed_card' is updated
  # the given block is executed. It is supposed to return an array of
  # cards whose solid caches are expired because of the update.
  # @param set_of_changed_card [set constant] a set of cards that triggers
  #   a cache update
  # @params args [Hash]
  # @option args [Symbol, Array of symbols] :on the action(s)
  #   (:create, :update, or :delete) on which the cache update
  #   should be triggered. Default is all actions.
  # @yield return an array of cards with solid cache that must be updated
  def cache_update_trigger set_of_changed_card, args={}, &block
    args[:on] ||= [:create, :update, :delete]
    name = event_name set_of_changed_card, args
    set_of_changed_card.class_eval do
      event name, :integrate, args do
        Array.wrap(yield(self)).compact.each do |expired_cache_card|
          next unless expired_cache_card.respond_to?(:update_solid_cache)
          expired_cache_card.update_solid_cache
        end
      end
    end
  end

  def event_name set, args
    changed_card_set = set.to_s.tr(":", "_").underscore
    solid_cache_set = to_s.tr(":", "_").underscore
    actions = Array.wrap(args[:on]).join('_')
    "update_#{solid_cache_set}_solid_cache_changed_by_" \
    "#{changed_card_set}_on_#{actions}".to_sym
  end
end

def expire_solid_cache
  return unless respond_to?(:solid_cache_card)
  Auth.as_bot do
    solid_cache_card.delete!
  end
end

def update_solid_cache
  return unless respond_to?(:calculate_count) &&
    respond_to?(:cached_count_card)
  new_count = calculate_count
  return unless new_count
  Card::Auth.as_bot do
    if cached_count_card.new_card?
      cached_count_card.update_attributes! content: new_count.to_s
    elsif new_count.to_s != cached_count_card.content
      cached_count_card.update_column :db_content, new_count.to_s
      cached_count_card.expire
    end
  end
  new_count
end

# called to refresh the cached count
# the default way is hthat the card is a search card and we just
# count the search result
# for special calculations override this method in your set
def calculate_count
  count
end

