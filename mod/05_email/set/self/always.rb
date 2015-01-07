include Card::FollowOption

self.follow_opts :position=>1

def exclusive
  true
end

def title
  'Following'
end

def form_label
  'follow'
end

def applies_to? card, user
  true
end