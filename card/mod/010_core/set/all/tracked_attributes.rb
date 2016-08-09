def assign_attributes args={}
  if args
    args = args.stringify_keys
    @set_specific = {}
    Card.set_specific_attributes.each do |key|
      @set_specific[key] = args.delete(key) if args[key]
    end

    new_type_id = extract_type_id! args unless args.delete("skip_type_lookup")
    subcard_args = extract_subcard_args! args
    args["type_id"] = new_type_id if new_type_id
    reset_patterns
  end
  params = ActionController::Parameters.new(args)
  params.permit!
  super params
  return unless args && subcard_args.present?
  # name= must come before process subcards
  subcards.add subcard_args
end

def assign_set_specific_attributes
  return unless @set_specific.present?
  @set_specific.each_pair do |name, value|
    send "#{name}=", value
  end
end

protected

def extract_subcard_args! args
  subcards = args.delete("subcards") || {}
  if (subfields = args.delete("subfields"))
    subfields.each_pair do |key, value|
      subcards[cardname.field(key)] = value
    end
  end
  args.keys.each do |key|
    subcards[key] = args.delete(key) if key =~ /^\+/
  end
  subcards
end

def extract_type_id! args={}
  type_id =
    case
    when args["type_id"]
      id = args.delete("type_id").to_i
      # type_id can come in as 0,'' or nil
      id == 0 ? nil : id
    when args["type_code"]
      Card.fetch_id args.delete("type_code").to_sym
    when args["type"]
      Card.fetch_id args.delete("type")
    else
      return nil
    end

  unless type_id
    errors.add :type, "#{args[:type] || args[:type_code]} is not a known type."
  end
  type_id
end

event :set_content, :store, on: :save do
  self.db_content = content || "" # necessary?
  self.db_content = Card::Content.clean!(db_content) if clean_html?
  @selected_action_id = @selected_content = nil
  clear_drafts
  reset_patterns_if_rule true
end

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
