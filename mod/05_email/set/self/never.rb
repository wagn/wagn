include Card::FollowOption

self.follow_opts :position=>3


def title
  'Ignoring'
end

def label
  'ignore'
end

def applies_to? card, user
  false
end