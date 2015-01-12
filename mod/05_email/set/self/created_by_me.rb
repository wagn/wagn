include Card::FollowOption

self.follow_opts :position=>2, :special=>true

def title
  'Following content you created'
end

def form_label
  'follow if I created'
end

def description set_card
  "#{set_card.follow_label} you created"
end

def applies_to? card, user
  card.creator and card.creator.type_id == Card::UserID and card.creator == user
end
