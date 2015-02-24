include Card::FollowOption

self.restrictive_follow_opts :position=>2

def applies_to? card, user_id
  Card.search(:editor_of=>card.name, :return=>:id).include? user_id
end

def title 
  'Following content you edited'
end

def label
  "follow what I've edited"
end
  
def description set_card
  "#{set_card.follow_label} I edited"
end



