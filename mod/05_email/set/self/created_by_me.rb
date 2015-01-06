include Card::FollowOption

self.follow_opts :position=>2, :special=>true


def description set_card
  "#{set_card.follow_label} you created"
end

def applies_to? card, user
  card.creator and card.creator.type_id == Card::UserID and card.creator == user
end
