# -*- encoding : utf-8 -*-

# A card that includes Abstract::SolidCache caches its core view
# in a '+*solid cache' card.
# If that card exists the core view returns its content as rendered view.
# If it doesn't exist the usual core view is rendered and saved in that card.
#
# The cache expiration can be controlled with the cache_update_trigger and
# cache_expire_trigger methods.

card_accessor :solid_cache, type: :html

format :html do
  def default_core_args args
    args[:solid_cache] = true unless args.key?(:solid_cache)
  end

  view :core do |args|
    return super(args) unless args[:solid_cache]

    subformat(card.solid_cache_card)._render_core args
  end
end

module ClassMethods
  # If a card of the set given by 'set_of_changed_card' is updated
  # the given block is executed. It is supposed to return an array of
  # cards whose solid caches are expired because of the update.
  # @param set_of_changed_card [set constant] a set of cards that triggers
  #   a cache update
  # @params args [Hash]
  # @option args [Symbol, Array of symbols] :on the action(s)
  #   (:create, :update, or :delete) on which the cache update
  #   should be triggered. Default is all actions.
  # @yield return an array of cards with solid cache that need to be updated
  def cache_update_trigger set_of_changed_card, args={}, &block
    define_event_to_update_expired_cached_cards(
      set_of_changed_card, args, :update_solid_cache, &block
    )
  end

  # Same as 'cache_update_trigger' but expires instead of updates the
  # outdated solid caches
  def cache_expire_trigger set_of_changed_card, args={}, &block
    define_event_to_update_expired_cached_cards(
      set_of_changed_card, args, :expire_solid_cache, &block
    )
  end

  def define_event_to_update_expired_cached_cards set_of_changed_card, args,
                                                  method_name
    args[:on] ||= [:create, :update, :delete]
    name = event_name set_of_changed_card, args
    Card::Set.register_set set_of_changed_card
    set_of_changed_card.event name, :finalize, args do
      Array(yield(self)).compact.each do |expired_cache_card|
        next unless expired_cache_card.solid_cache?
        expired_cache_card.send method_name
      end
    end
  end

  def event_name set, args
    changed_card_set = set.to_s.tr(":", "_").underscore
    solid_cache_set = to_s.tr(":", "_").underscore
    actions = Array.wrap(args[:on]).join("_")
    "update_#{solid_cache_set}_solid_cache_changed_by_" \
    "#{changed_card_set}_on_#{actions}".to_sym
  end
end

def expire_solid_cache
  return unless solid_cache?
  Auth.as_bot do
    solid_cache_card.delete!
  end
end

def update_solid_cache
  return unless solid_cache?
  new_content = format(:html)._render_core(solid_cache: false)
  return unless new_content
  write_to_solid_cache new_content
  new_content
end

def write_to_solid_cache new_content
  Auth.as_bot do
    if solid_cache_card.new_card?
      solid_cache_card.update_attributes! content: new_content
    elsif new_content != solid_cache_card.content
      solid_cache_card.update_column :db_content, new_content
      solid_cache_card.expire
    end
  end
end
