@@options = {
  junction_only: true,
  assigns_type: true,
  anchor_parts_count: 2
}

def label name
  %(All "+#{name.to_name.tag}" cards on "#{name.to_name.left_name}" cards)
end

def prototype_args anchor
  {
    name: "+#{anchor.tag}",
    supercard: Card.new(name: "*dummy", type: anchor.trunk_name)
  }
end

def anchor_name card
  left = card.left
  type_name = (left && left.type_name) || Card[Card.default_type_id].name
  "#{type_name}+#{card.cardname.tag}"
end

def follow_label name
  %(all "+#{name.to_name.tag}" on "#{name.to_name.left_name}s")
end
