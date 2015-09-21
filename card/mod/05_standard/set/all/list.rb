event :trunk_cardtype_of_a_list_relation_changed, :changed=>:type_id, :after=>:store, :on=>:update, :when => proc {|c| Codename[:list] } do
  type_key_was = (tk = Card.fetch(type_id_was)) && tk.key
  if (list_cards = Card.search(:left=>name, :type_id=>Card::ListID))
    list_cards.each do |card|
      card.update_listed_by_cache_for card.item_keys, :type_key => type_key_was
      card.update_listed_by_cache_for card.item_keys
    end
  end
  if (listed_by_cards = Card.search(:left=>name, :type_id=>Card::ListedByID))
    listed_by_cards.each do |card|
      card.update_cached_list
    end
  end
end

event :trunk_name_of_a_list_relation_changed, :changed=>:name, :after=>:store, :on=>:update, :when => proc {|c| Codename[:list] } do
  if (list_cards = Card.search(:left=>name, :type_id=>Card::ListID))
    list_cards.each do |card|
      card.update_listed_by_cache_for card.item_keys
    end
  end
  if (listed_by_cards = Card.search(:left=>name, :type_id=>Card::ListedByID))
    listed_by_cards.each do |card|
      card.update_cached_list
    end
  end
end