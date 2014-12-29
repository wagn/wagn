include Card::FollowOption

self.follow_opts :position=>1

def applies_to? card, user
  true
end