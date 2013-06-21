@@options = { :junction_only => true }

def label name
  'All "+*" cards'
end

def prototype_args anchor
  { :name=>'*dummy+*dummy' }
end

def pattern_applies? card
  card.cardname.rstar?
end