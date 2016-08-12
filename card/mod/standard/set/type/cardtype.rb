
format :html do
  view :type do |args|
    args[:type_class] = "no-edit" if card.cards_of_type_exist?
    super args
  end

  view :type_formgroup do |args|
    if card.cards_of_type_exist?
      %(
        <div>
          Sorry, this card must remain a Cardtype so long as there are
          <strong>#{card.name}</strong> cards.
        </div>
      )
    else
      super args
    end
  end

  view :add_link do |args|
    args[:title] ||= "Add #{card.name}"
    link_to _render_title(args), _render_add_path(args), class: args[:css_class]
  end

  view :add_button, view: :add_link
  def default_add_button_args args
    args[:css_class] = "btn btn-default"
  end

  view :add_url do |args|
    card_url _render_add_path(args)
  end

  view :add_path do |args|
    path_args = {}
    if args[:params]
      context = ((@parent && @parent.card) || card).name
      Rack::Utils.parse_nested_query(args[:params]).each do |key, value|
        value = value.to_name.to_absolute(context) if value
        key = key.to_name.to_absolute(context)
        path_args[key] = value
      end
    end
    path_args[:action] = "new"
    page_path card.cardname, path_args
  end
end

include Basic

def follow_label
  default_follow_set_card.follow_label
end

def followed_by? user_id=nil
  default_follow_set_card.all_members_followed_by? user_id
end

def default_follow_set_card
  # FIXME: use codename
  Card.fetch("#{name}+*type")
end

def cards_of_type_exist?
  # FIXME: faster test than counting all of type?
  !new_card? && Auth.as_bot { Card.count_by_wql type_id: id } > 0
end

event :check_for_cards_of_type, after: :validate_delete do
  if cards_of_type_exist?
    errors.add :cardtype, "can't alter this type; #{name} cards still exist"
  end
end
