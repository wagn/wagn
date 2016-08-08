include Card::FollowOption

follow_opts position: 3

follow_test { |_follower_id, _accounted_ids| false }

def title
  "Ignoring"
end

def label
  "ignore"
end
