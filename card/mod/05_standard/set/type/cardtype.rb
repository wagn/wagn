
format :html do

  view :type do |args|
    args.merge!(:type_class=>'no-edit') if card.cards_of_type_exist?
    super args
  end

  view :type_fieldset do |args|
    if card.cards_of_type_exist?
      %{<div>Sorry, this card must remain a Cardtype so long as there are <strong>#{ card.name }</strong> cards.</div>}
    else
      super args
    end  
  end

  view :watch do |args|
    wrap args do
      link_args = if card.watched? 
        [card, "following", :off, "stop sending emails", { :hover_content=> 'unfollow' } ]
      else
        [card, "follow all", :on, "send emails"]
      end
      link_args[3] += " about changes to #{card.cardname} cards"
      watch_link( *link_args )
    end
  end
end

include Basic



def cards_of_type_exist?
  !new_card? and Auth.as_bot { Card.count_by_wql :type_id=>id } > 0
end

event :check_for_cards_of_type, :after=>:validate_delete do
  if cards_of_type_exist?
    errors.add :cardtype, "can't alter this type; #{name} cards still exist"
  end
end
