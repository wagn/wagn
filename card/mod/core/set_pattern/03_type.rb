def label name
  %(All "#{name}" cards)
end

def prototype_args anchor
  { type: anchor }
end

def pattern_applies? card
  !!card.type_id
end

def anchor_name card
  card.type_name
end

def anchor_id card
  card.type_id
end

def follow_label name
  %(all "#{name}s")
end
