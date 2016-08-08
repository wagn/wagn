@@options = { junction_only: true }

def label _name
  'All "+*" cards'
end

def prototype_args _anchor
  { name: "*dummy+*dummy" }
end

def pattern_applies? card
  card.cardname.rstar?
end

def follow_label _name
  'all "+*" cards'
end
