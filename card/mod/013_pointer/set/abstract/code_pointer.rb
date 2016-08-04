def raw_content
  item_codenames.map do |codename|
    Card[codename].name
  end.to_pointer_content
end
basket :item_codenames
