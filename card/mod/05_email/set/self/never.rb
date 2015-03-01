include Card::FollowOption

self.follow_opts :position=>3

def applies_to? card, user_id
  false
end

def title
  'Ignoring'
end

def label
  'ignore'
end

