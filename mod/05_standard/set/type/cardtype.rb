
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

  view :follow_link do |args|
    cardtype_followed = ["#{card.name}+*type", "*all"].select do |set_name| 
        follow_card = Card.fetch("#{set_name}+#{Card[:follow].name}+#{Auth.current.name}")
        follow_card && follow_card.item_names.include?('always')
      end.present?
      
    super args.merge(:toggle=>( cardtype_followed ? :off : :on) )
  end
  
  
  def default_follow_set_card
    Card.fetch("#{card.name}+*type")
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
