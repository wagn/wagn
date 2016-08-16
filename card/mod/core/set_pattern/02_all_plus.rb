@@options = { junction_only: true }

def label _name
  'All "+" cards'
end

def prototype_args _anchor
  { name: "+" }
end

def follow_label _name
  'all "+" cards'
end
