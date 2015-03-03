include All::Permissions::Follow

def options 
  Card::FollowOption.cards.compact
end

def options_card
  Card.new :name=>'follow_options_card', :type_code=>:pointer, :content=>options.map {|oc| "[[#{oc.title}]]" }.join("\n")
end
