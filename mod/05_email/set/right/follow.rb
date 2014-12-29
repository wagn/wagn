# event :follow_change, :on=>:save, :before=>:store do
#   subcards["+#{Auth.current.name}"] = {:content => content}
#   following = Auth.current.following_card
#   #if new_card?
#
#   if not new_card?
#     following.drop_item "#{left}+#{was_content}"
#   end
#   following.add_item "#{left}+#{content}"
#   subcards[following.name] = {:content => following.content}
# end