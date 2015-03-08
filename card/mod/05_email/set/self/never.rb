include Card::FollowOption

self.follow_opts :position=>3

self.follow_test { |opts| false }


def title
  'Ignoring'
end

def label
  'ignore'
end

