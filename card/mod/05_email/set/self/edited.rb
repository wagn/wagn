include Card::FollowOption

self.restrictive_follow_opts :position=>2

def applies_to? card, user_id
  #return false
  card.editor_ids_follow_cache.find { |editor_id| editor_id.to_i == user_id }
end

def title 
  'Following content you edited'
end

def label
  "follow if I edited"
end
  
def description set_card
  "#{set_card.follow_label} I edited"
end



