include All::Permissions::Follow

def option_cards
  Card::FollowOption.cards.compact
end

def options_rule_card
  Card.new(
    name: "follow_options_card",
    type_code: :pointer,
    content: option_cards.map { |oc| "[[#{oc.name}]]" }.join("\n")
  )
end

format :html do
  def default_follow_item_args args
    args[:condition] ||= Env.params[:condition] || "*always"
  end

  view :follow_item, tags: :unknown_ok do |args|
    if card.new_card? || !card.include_item?(args[:condition])
      button_view = :add_follow_rule_button
      form_opts = { add_item: args[:condition] }
    else
      button_view = :delete_follow_rule_button
      form_opts = { drop_item: args[:condition] }
    end

    text = if (option_card = Card.fetch args[:condition])
             option_card.description(card.rule_set)
           else
             card.rule_set.follow_label
           end
    link_target = if card.rule_set.tag.codename == "self"
                    card.rule_set_name.left
                  else
                    "#{card.rule_set_name}+by name"
                  end
    wrap do
      card_form(
        { action: :update, name: card.name, success: { view: :follow_item } },
        hidden: { condition: args[:condition] }.merge(form_opts)
      ) do
        output [
          _optional_render(button_view, args),
          link_to_card(link_target, text)
        ]
      end
    end
  end

  def default_follow_status_args args
    args[:card_key] ||= card.set_prototype.key
  end

  view :follow_status do |args|
    ["<h4>Get notified about changes</h4>",
     render(:follow_status_delete_options),
     follow_status_link(card.name, args[:card_key])].join "\n\n"
  end

  def follow_status_link name, key
    link_to_related key, "more options",
                    path: { related: { name: name, view: :edit_single_rule } },
                    class: "btn update-follow-link", "data-card_key" => key
  end

  view :follow_status_delete_options, cache: :never do
    wrap_with(:ul, class: "delete-list list-group") do
      card.item_names.map do |option|
        wrap_with :li, class: "list-group-item" do
          condition = option == "*never" ? "*always" : option
          subformat(card).render_follow_item condition: condition
        end
      end.join "\n"
    end
  end

  view :delete_follow_rule_button do
    button_tag(
      type: :submit,
      class: "btn-xs btn-item-delete btn-primary", "aria-label" => "Left Align"
    ) do
      tag :span, class: "glyphicon glyphicon-ok", "aria-hidden" => "true"
    end
  end

  view :add_follow_rule_button do
    button_tag(
      type: :submit,
      class: "btn-xs btn-item-add", "aria-label" => "Left Align"
    ) do
      tag :span, class: "glyphicon glyphicon-plus", "aria-hidden" => "true"
    end
  end
end
