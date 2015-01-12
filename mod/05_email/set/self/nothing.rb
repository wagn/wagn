include Card::FollowOption

self.follow_opts :position=>0

def exclusive
  true
end

def title
  'Ignoring'
end

def form_label
  '--'
end

def applies_to? card, user
  true
end