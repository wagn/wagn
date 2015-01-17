include Card::FollowOption

self.restrictive_follow_opts :position=>2

def title 
  'Following content you edited'
end

def form_label
  'that I edited'
end
  
def description set_card
  "#{set_card.follow_label} you edited"
end


def applies_to? card, user
  Card.search(:editor_of=>card.name).include? user
end
