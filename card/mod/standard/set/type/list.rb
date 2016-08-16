include_set Pointer

event :validate_list_name, :validate, on: :save, changed: :name do
  if !junction? || !right || right.type_id != CardtypeID
    errors.add :name, "must have a cardtype name as right part"
  end
end

event :validate_list_item_type_change, :validate,
      on: :save, changed: :name do
  item_cards.each do |item_card|
    next unless item_card.type_cardname.key != item_type_name.key
    errors.add :name,
               "name conflicts with list items' type; " \
               "delete content first"
  end
end

event :validate_list_content, :validate,
      on: :save, changed: :content do
  item_cards.each do |item_card|
    next unless item_card.type_cardname.key != item_type_name.key
    errors.add :content,
               "#{item_card.name} has wrong cardtype; " \
               "only cards of type #{cardname.right} are allowed"
  end
end

event :create_listed_by_cards, :prepare_to_validate,
      on: :save, changed: :content do
  item_names.each do |item_name|
    listed_by_name = "#{item_name}+#{left.type_name}"
    next if director.main_director.card.key == listed_by_name.to_name.key
    if !Card[listed_by_name]
      add_subcard listed_by_name, type_id: ListedByID
    else
      Card[listed_by_name].update_references_out
    end
  end
end

event :update_related_listed_by_card_on_create, :finalize,
      on: :create do
  update_listed_by_cache_for item_keys
end

event :update_related_listed_by_card_on_content_update, :finalize,
      on: :update, changed: :content do
  new_items = item_keys
  changed_items =
    if db_content_was
      old_items = item_keys(content: db_content_was)
      old_items + new_items - (old_items & new_items)
    else
      new_items
    end
  update_listed_by_cache_for changed_items
end

event :update_related_listed_by_card_on_name_and_type_changes, :finalize,
      on: :update, changed: [:name, :type_id] do
  update_all_items
end

event :update_related_listed_by_card_on_delete, :finalize,
      on: :delete, when: proc { |c| c.junction? } do
  update_listed_by_cache_for item_keys, type_key: @left_type_key
end

event :cache_type_key, :store,
      on: :delete, when: proc { |c| c.junction? } do
  @left_type_key = left.type_card.key
end

def update_all_items
  current_items = item_keys
  if db_content_was
    old_items = item_keys(content: db_content_was)
    update_listed_by_cache_for old_items
  end
  update_listed_by_cache_for current_items
end

def update_listed_by_cache_for item_keys, args={}
  type_key = args[:type_key] || left.type_card.key

  item_keys.each do |item_key|
    key = "#{item_key}+#{type_key}"
    next unless Card::Cache[Card::Set::Type::ListedBy].exist? key
    if (card = Card.fetch(key))
      card.update_cached_list
      card.update_references_out
    else
      Card::Cache[Card::Set::Type::ListedBy].delete key
    end
  end
end

def item_type
  cardname.right
end

def item_type_name
  cardname.right_name
end

def item_type_card
  cardname.right
end

def item_type_id
  right.id
end
