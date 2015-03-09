include Card::FollowOption

self.follow_opts :position=>3

self.follow_test { |follower_id, accounted_ids| false }


def title
  'Ignoring'
end

def label
  'ignore'
end

