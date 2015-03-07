include Card::FollowOption

self.follow_opts :position=>2

self.follow_test do |opts|
  true
end

def title
  'Following'
end

def label
  'follow'
end

