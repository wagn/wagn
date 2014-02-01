# -*- encoding : utf-8 -*-

format :html do

  view :type do |args|
    args.merge!(:type_class=>'no-edit') if card.cards_of_type_exist?
    _final_type args
  end

  view :watch do |args|
    wrap :watch, args do
      #type_link = card.watching_type? ? "#{watching_type_cards} | " : ""
      link_args = if card.watching?
        ["following", :off, "stop sending emails about changes to #{card.cardname}", { :hover_content=> 'unfollow' } ]
      else
        ["follow all", :on, "send emails about changes to #{card.cardname}"]
      end
      link_args[2] += ' cards'
      #type_link + 
      watch_link( *link_args )
    end
  end
end

include Card::Set::Type::Basic



def cards_of_type_exist?
  Account.as_bot { Card.count_by_wql :type_id=>id } > 0
end

event :check_for_cards_of_type, :after=>:validate_delete do
  if cards_of_type_exist?
    errors.add :cardtype, "can't alter this type; #{name} cards still exist"
  end
end
