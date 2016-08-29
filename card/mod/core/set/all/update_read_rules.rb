
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

def update_read_rules_not_overidden_by_narrower_rules cur_index,
                                                      rule_class_index, set
  set.item_cards(limit: 0).each_with_object(::Set.new) do |item_card, in_set|
    in_set << item_card.key
    next if cur_index < rule_class_index
    item_card.update_read_rule
  end
end

def update_read_rules_of_set_members set
  return ::Set.new if trash || !(class_id = set_class_id(set))
  rule_class_ids = set_patterns.  map(&:pattern_id)
  Auth.as_bot do
    cur_index = rule_class_ids.index Card[read_rule_class].id
    if (rule_class_index = rule_class_ids.index(class_id))
      update_read_rules_not_overridden_by_narrower_rules cur_index,
                                                         rule_class_index, set
    else
      warn "No current rule index #{class_id}, #{rule_class_ids.inspect}"
      ::Set.new
    end
  end
end

def set_class_id set
  set && (set_class = set.tag) && set_class.id
end


def update_read_ruled_cards set
  self.class.clear_read_rule_cache
  Card.cache.reset # maybe be more surgical, just Auth.user related
  expire # probably shouldn't be necessary,
  # but was sometimes getting cached version when card should be in the
  # trash.  could be related to other bugs?

  updated = update_read_rules_of_set_members set

  # then find all cards with me as read_rule_id that were not just updated
  # and regenerate their read_rules
  return if new_card?
  Card.search(read_rule_id: id) do |card|
    card.update_read_rule unless updated.include?(card.key)
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
