include Card::FollowOption

follow_opts position: 2

follow_test { |_follower_id, _accounted_ids| true }

def title
  "Following"
end

def label
  "follow"
end
