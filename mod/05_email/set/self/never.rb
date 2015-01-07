include Card::FollowOption

self.follow_opts :position=>4

def exclusive
  true
end

def title
  'Ignoring'
end

def form_label
  'ignore'
end

def applies_to? card, user
  false
end