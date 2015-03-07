include Card::FollowOption

self.restrictive_follow_opts :position=>1

self.follow_test do |opts|
  opts[:creator_id] == opts[:user_id]
end

self.follow_test_option :creator_id do |card|
  card.creator_id
end

#def applies_to? card, user_id
#  card.creator and card.creator.type_id == Card::UserID and card.creator.id == user_id
#end

def title
  'Following content you created'
end

def label
  "follow if I created"
end

def description set_card
  "#{set_card.follow_label} I created"
end

