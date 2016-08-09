def label _name
  'All "*" cards'
end

def prototype_args _anchor
  { name: "*dummy" }
end

def pattern_applies? card
  card.cardname.star?
end

def follow_label _name
  'all "*" cards'
end
