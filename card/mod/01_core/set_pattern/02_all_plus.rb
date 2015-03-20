@@options = { :junction_only => true }

def label name
  'All "+" cards'
end

def prototype_args anchor
  { :name=>'+' }
end

def follow_label name
  'all "+" cards'
end
