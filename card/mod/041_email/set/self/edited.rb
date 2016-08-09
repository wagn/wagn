include Card::FollowOption

restrictive_follow_opts position: 2

follower_candidate_ids do |card|
  # FIXME? - could optimize by not using cards table...
  Card.search editor_of: card.name, return: :id
end

def title
  "Following content you edited"
end

def label
  "follow if I edited"
end

def description set_card
  "#{set_card.follow_label} I edited"
end
