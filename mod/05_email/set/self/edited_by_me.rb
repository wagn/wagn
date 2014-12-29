include Card::FollowOption

follow_opts :position=>3

def followed?
  if Auth.current
    Auth.current.fetch(:trait=>:following, :new=>{}).include_item? cardname 
  end
end
  
def follow_label
  'content I edited'
end

def applies_to? card, user
  Card.search(:editor_of=>card.name).include? user
end

def follower_ids args={}
  Card.search(:editor_of=>args[:context].name).select do |editor|
    editor and editor.type_id == Card::UserID and editor.following? cardname
  end.map(&:id)
end


def followers_of card
  Card.search(:editor_of=>card.name).select do |editor|
    editor and editor.type_id == Card::UserID and editor.following? cardname
  end
end