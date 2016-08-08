include Card::Set::Type::Pointer

def raw_content
  item_names.map { |name| "[[#{name}]]" }
end

def item_names
  if (user = left)
    Card.preference_names user.name, "follow"
  else
    []
  end
end

def item_cards
  item_names.map { |name| Card.fetch name }
end

def virtual?
  !real?
end

format { include Card::Set::Type::Pointer::Format }

format :html do
  include Card::Set::Type::Pointer::HtmlFormat

  view :closed_content do |_args|
    ""
  end

  view :core do |args|
    <<-HTML
      <div role="tabpanel">
        <ul class="nav nav-tabs" role="tablist" id="myTab">
          <li role="presentation" class="active">
             <a href="#following" aria-controls="following"
                role="tab" data-toggle="tab">Follow</a>
          </li>
          <li role="presentation">
            <a href="#ignoring" aria-controls="ignoring"
               role="tab" data-toggle="tab">Ignore</a>
          </li>
        </ul>
        <div class="tab-content">
          <div role="tabpanel" class="tab-pane active" id="following">
            #{render_following_list args}
          </div>
          <div role="tabpanel" class="tab-pane" id="ignoring">
            #{render_ignoring_list}
          </div>
        </div>
      </div>
    HTML
  end

  def followed_by_option
    hash = Hash.new { |h, k| h[k] = [] }
    card.item_cards.each do |follow_rule|
      follow_rule.item_cards.each do |follow_option|
        hash[follow_option.codename.to_sym] << follow_rule
      end
    end
  end

  def each_suggestion
    return unless (suggestions = Card["follow suggestions"])
    suggestions.item_names.each do |sug|
      set_card = Card.fetch sug.to_name.left
      if set_card && set_card.type_code == :set
        sugtag = sug.to_name.right
        option_card = Card.fetch(sugtag) || Card[sugtag.to_sym]
        option = option_card.follow_option? ? option_card.name : "*always"
        yield(set_card, option)
      elsif (set_card = Card.fetch sug) && set_card.type_code == :set
        yield(set_card, "*always")
      end
    end
  end

  # returns hashes with existing and suggested follow options
  # structure:
  # set_pattern_class =>
  #  [ {card: rule_card, options: ['*always', '*created'] },.... ]
  def followed_by_set
    res = Hash.new { |h, k| h[k] = [] }
    never = Card[:never].name
    card.item_cards.each do |follow_rule|
      options = follow_rule.item_names.reject { |item| item == never }
      res[follow_rule.rule_set.subclass_for_set] << { card: follow_rule,
                                                      options: options }
    end

    if Auth.signed_in? && Auth.current_id == card.left.id
      each_suggestion do |set_card, option|
        suggested_rule_name = set_card.follow_rule_name(card.trunk)
        rule = res[set_card.subclass_for_set].find do |rule|
          rule[:card].name == suggested_rule_name
        end
        if rule
          rule[:options] << option unless rule[:options].include? option
        else
          rule_card = Card.new(name: suggested_rule_name)
          res[set_card.subclass_for_set] << { card: rule_card,
                                              options: [option] }
        end
      end
    end
    res
  end

  view :following_list do |_args|
    if !Auth.signed_in? || Auth.current_id != card.left.id
      hide_buttons = [:delete_follow_rule_button, :add_follow_rule_button]
    end

    sets = followed_by_set
    wrap_with :div, class: "pointer-list-editor" do
      wrap_with :ul, class: "delete-list list-group" do
        Card.set_patterns.select { |p| sets[p] }.reverse.map do |set_pattern|
          sets[set_pattern].map do |rule|
            rule[:options].map do |option|
              content_tag :li, class: "list-group-item" do
                subformat(rule[:card]).render_follow_item condition: option,
                                                          hide: hide_buttons
              end
            end.join("\n")
          end.join("\n")
        end.join("\n")
      end
    end
  end

  view :ignoring_list do |_args|
    ignore_list = []
    card.item_cards.each do |follow_rule|
      follow_rule.item_cards.each do |follow_option|
        ignore_list << follow_rule if follow_option.codename.to_sym == :never
      end
    end
    if !Auth.signed_in? || Auth.current_id != card.left.id
      hide_buttons = [:delete_follow_rule_button, :add_follow_rule_button]
    end
    never = Card[:never].name
    wrap_with :div, class: "pointer-list-editor" do
      wrap_with :ul, class: "delete-list list-group" do
        ignore_list.map do |rule_card|
          content_tag :li, class: "list-group-item" do
            subformat(rule_card).render_follow_item condition: never,
                                                    hide: hide_buttons
          end
        end.join "\n"
      end
    end
  end

  view :pointer_items, tags: :unknown_ok do |args|
    super(args.merge(item: :link))
  end

  view :errors, perms: :none do |args|
    if card.errors.any?
      if card.errors.find { |attrib, _msg| attrib == :permission_denied }
        Env.save_interrupted_action(request.env["REQUEST_URI"])
        title = "Problems with #{card.name}"
        frame args.merge(panel_class: "panel panel-warning",
                         title: title, hide: "menu") do
          "Please #{link_to 'sign in', card_url(':signin')}" # " #{to_task}"
        end
      else
        super(args)
      end
    end
  end
end

format(:css) { include Card::Set::Type::Pointer::CssFormat }
