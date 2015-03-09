include Card::FollowOption

self.follow_opts :position=>2

self.follow_test { |follower_id, accounted_ids| true }

def title
  'Following'
end

def label
  'follow'
end

