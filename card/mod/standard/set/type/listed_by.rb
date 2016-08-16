include_set Pointer

event :validate_listed_by_name, :validate, on: :save, changed: :name do
  if !junction? || !right || right.type_id != CardtypeID
    errors.add :name, "must have a cardtype name as right part"
  end
end

event :validate_listed_by_content, :validate,
      on: :save, changed: :content do
  item_cards(content: content).each do |item_card|
    next unless item_card.type_id != right.id
    errors.add(
      :content,
      "#{item_card.name} has wrong cardtype; " \
      "only cards of type #{cardname.right} are allowed"
    )
  end
end

event :update_content_in_list_cards, :prepare_to_validate,
      on: :save, changed: :content do
  if content.present?
    new_items = item_keys(content: content)
    old_items = item_keys
    removed_items = old_items - new_items
    added_items   = new_items - old_items
    removed_items.each do |item|
      if (lc = list_card(item))
        lc.drop_item cardname.left
        subcards.add lc
      end
    end
    added_items.each do |item|
      if (lc = list_card(item))
        lc.add_item cardname.left
        subcards.add lc
      else
        subcards.add(
          name: "#{Card[item].name}+#{left.type_name}", type: "list",
          content: "[[#{cardname.left}]]"
        )
      end
    end
  end
end

def raw_content
  Card::Cache[Card::Set::Type::ListedBy].fetch(key) do
    generate_content
  end
end

def generate_content
  listed_by.map do |item|
    "[[%s]]" % item.to_name.left
  end.join "\n"
end

def listed_by
  Card.search(
    { type: "list", right: trunk.type_name,
      left: { type: cardname.tag }, refer_to: cardname.trunk, return: :name
      }, "listed_by" # better wql comment would be...better
  )
end

def update_cached_list
  Card::Cache[Card::Set::Type::ListedBy].write key, generate_content
end

def list_card item
  Card.fetch item, left.type_name
end

def unfilled?
  false
end
