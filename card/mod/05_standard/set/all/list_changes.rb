# -*- encoding : utf-8 -*-

def list_fields
  Card.search({ left: name, type_id: Card::ListID }, "list fields")
end

def listed_by_fields
  Card.search({ left: name, type_id: Card::ListedByID }, "listed by fields")
end

def linker_lists
  Card.search({ type_id: Card::ListID, link_to: name },
              "lists that link to #{name}")
end

event :trunk_cardtype_of_a_list_relation_changed, :finalize,
      changed: :type, on: :update,
      when: proc { Codename[:list] } do
  type_key_was = (tk = Card.quick_fetch(type_id_was)) && tk.key

  list_fields.each do |card|
    card.update_listed_by_cache_for card.item_keys, type_key: type_key_was
    card.update_listed_by_cache_for card.item_keys
  end
  listed_by_fields.each &:update_cached_list
end

event :trunk_name_of_a_list_relation_changed, :finalize,
      changed: :name,  on: :update,
      when: proc { Codename[:list] } do
  list_fields.each do |card|
    card.update_listed_by_cache_for card.item_keys
  end
  listed_by_fields.each &:update_cached_list
end

event :cardtype_of_list_item_changed, :validate,
      changed: :type, on: :save,
      when: proc { Codename[:list] } do
  linker_lists.each do |card|
    next unless card.item_type_id != type_id
    errors.add(:type,
               "can't be changed because #{name} " \
               "is referenced by list card #{card.name}")
  end
end
