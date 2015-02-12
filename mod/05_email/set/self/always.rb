include Card::FollowOption

self.follow_opts :position=>2

def applies_to? card, user
  true
end

def title
  'Following'
end

def label
  'follow'
end

