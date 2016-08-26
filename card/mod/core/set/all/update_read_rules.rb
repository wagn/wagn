
# FIXME: the following don't really belong here, but they have to come after
# the reference stuff.  we need to organize a bit!

event :update_ruled_cards, :finalize do
  if is_rule?
    # warn "updating ruled cards for #{name}"
    self.class.clear_rule_cache
    set = rule_set

    if right_id == Card::ReadID && (name_changed? || trash_changed?)
      update_read_ruled_cards set
    end
  end
end

def update_read_rules_of_set_members_not_governed_by_narrower_rules set
  return {} if trash || !set || !(set_class = set.tag) ||
    !(class_id = set_class.id)
  in_set = {}
  rule_class_ids = set_patterns.map(&:pattern_id)
  Auth.as_bot do
    cur_index = rule_class_ids.index Card[read_rule_class].id
    if (rule_class_index = rule_class_ids.index(class_id))
      set.item_cards(limit: 0).each do |item_card|
        in_set[item_card.key] = true
        next if cur_index < rule_class_index
        item_card.update_read_rule if cur_index >= rule_class_index
      end
    else
      warn "No current rule index #{class_id}, #{rule_class_ids.inspect}"
    end
  end
  in_set
end

def update_read_ruled_cards set
  self.class.clear_read_rule_cache
  Card.cache.reset # maybe be more surgical, just Auth.user related
  expire # probably shouldn't be necessary,
  # but was sometimes getting cached version when card should be in the
  # trash.  could be related to other bugs?

  updated = update_read_rules_of_set_members_not_governed_by_narrower_rules set

  # then find all cards with me as read_rule_id that were not just updated
  # and regenerate their read_rules
  return if new_card?
  Card.search(read_rule_id: id) do |card|
    card.update_read_rule unless updated[card.key]
  end
end

event :process_read_rule_update_queue, :finalize do
  Array.wrap(@read_rule_update_queue).each(&:update_read_rule)
  @read_rule_update_queue = []
end

event :expire_related, :finalize do
  subcards.keys.each do |key|
    Card.cache.soft.delete key
  end
  expire # FIXME: where do we put this. Here it deletes @stage
  reset_patterns
  if is_structure?
    structuree_names.each do |name|
      Card.expire name
    end
  end
end

event :expire_related_names, before: :expire_related, changed: :name do
  # FIXME: look for opportunities to avoid instantiating the following
  descendants.each(&:expire)
  name_referers.each(&:expire)
end
