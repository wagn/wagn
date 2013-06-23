def label name
  'Accounted "+" cards'
end

def prototype_args anchor
  {:name=>'*dummy+*account'}
end

def pattern_applies? card
  !card.new_card? and cd = card.fetch(:skip_virtual=>true,:skip_modules=>true,:trait=>:account) and !cd.new_card?
end
