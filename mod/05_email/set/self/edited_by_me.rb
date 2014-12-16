include Card::FollowOption

follow_opts :position=>2

def followed?
  if Auth.current
    Auth.current.fetch(:trait=>:following, :new=>{}).include_item? cardname 
  end
end
  
def follow_label
  'content I edited'
end

def applies? user, card 
  Card.search(:editor_of=>card.name).include? user
end

def followers_of card
  Card.search(:editor_of=>card.name).select do |editor|
    editor and editor.type_id == Card::UserID and editor.following? cardname
  end
end