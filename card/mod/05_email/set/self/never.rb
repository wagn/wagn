include Card::FollowOption

self.follow_opts :position=>3

self.follow_test do |opts|
  false
end


def title
  'Ignoring'
end

def label
  'ignore'
end

