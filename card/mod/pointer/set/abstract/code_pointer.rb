include_set Abstract::Pointer

abstract_basket :item_codenames

def raw_content
  item_codenames.map do |codename|
    Card[codename] && Card[codename].name
  end.compact.to_pointer_content
end
