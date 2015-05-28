
format :html do

  view :type do |args|
    args.merge!(:type_class=>'no-edit') if card.cards_of_type_exist?
    super args
  end

  view :type_formgroup do |args|
    if card.cards_of_type_exist?
      %{<div>Sorry, this card must remain a Cardtype so long as there are <strong>#{ card.name }</strong> cards.</div>}
    else
      super args
    end
  end

  view :add_button do |args|
    args[:title] ||= "Add #{card.name}"
    if args[:params]
      context = ((@parent && @parent.card) || card).name
      args[:params].gsub!(/=([^&]+)/) do |match|
        "=#{$1.to_name.to_absolute context}"
      end
    end
    %{
      <a class='btn btn-default' href='/new/#{card.key}?#{args[:params]}'>
        #{ _render_title args }
      </a>
    }
  end
end


include Basic


def follow_label
  default_follow_set_card.follow_label
end

def followed_by? user_id = nil
  default_follow_set_card.all_members_followed_by? user_id
end

def default_follow_set_card
  Card.fetch("#{name}+*type")
end


def cards_of_type_exist?
  !new_card? and Auth.as_bot { Card.count_by_wql :type_id=>id } > 0
end

event :check_for_cards_of_type, :after=>:validate_delete do
  if cards_of_type_exist?
    errors.add :cardtype, "can't alter this type; #{name} cards still exist"
  end
end
