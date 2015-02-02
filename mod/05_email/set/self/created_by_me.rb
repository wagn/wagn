include Card::FollowOption

self.restrictive_follow_opts :position=>1

def title
  'Following content you created'
end

def label
  'follow if created by me'
end

def description set_card
  "#{set_card.follow_label} you created"
end

def applies_to? card, user
  card.creator and card.creator.type_id == Card::UserID and card.creator == user
end
