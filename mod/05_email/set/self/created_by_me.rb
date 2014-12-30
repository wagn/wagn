include Card::FollowOption

self.follow_opts :position=>2


def followed?
  if Auth.current
    Auth.current.fetch(:trait=>:following, :new=>{}).include_item? cardname 
  end
end


def follow_label
  'content I created'
end

def applies_to? card, user
  card.creator and card.creator.type_id == Card::UserID and card.creator == user
end

def follower_ids args={}
  if card=args[:context] and card.creator and card.creator.type_id == Card::UserID and card.creator.following? cardname
    [card.creator.id]
  else
    []
  end
end
  
def followers_of card
  if card.creator and card.creator.type_id == Card::UserID and card.creator.following? cardname
    [card.creator]
  else
    []
  end
end

