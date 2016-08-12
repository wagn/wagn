event :add_and_drop_items, :prepare_to_validate, on: :save do
  adds = Env.params["add_item"]
  drops = Env.params["drop_item"]
  Array.wrap(adds).each { |i| add_item i } if adds
  Array.wrap(drops).each { |i| drop_item i } if drops
end

event :insert_item_event, :prepare_to_validate,
      on: :save, when: proc { Env.params["insert_item"] } do
  index = Env.params["item_index"] || 0
  insert_item index.to_i, Env.params["insert_item"]
end

format :html do
  #  view :edit do |args|
  #    super(args.merge(pointer_item_class: 'form-control'))
  #  end

  view :editor do |args|
    part_view = (c = card.rule(:input)) ? c.gsub(/[\[\]]/, "") : :list
    hidden_field(:content, class: "card-content") +
      raw(_render(part_view, args))
    # .merge(pointer_item_class: 'form-control')))
  end

  view :list do |args|
    args ||= {}
    items = args[:item_list] || card.item_names(context: :raw)
    items = [""] if items.empty?
    rendered_items = items.map do |item|
                       _render_list_item args.merge(pointer_item: item)
                     end.join "\n"
    extra_css_class = args[:extra_css_class] || "pointer-list-ul"

    <<-HTML
      <ul class="pointer-list-editor #{extra_css_class}"
          data-options-card="#{options_card_name}">
        #{rendered_items}
      </ul>
      #{add_item_button}
    HTML
  end

  def options_card_name
    (oc = card.options_rule_card) ? oc.cardname.url_key : ":all"
  end

  def add_item_button
    content_tag :span, class: "input-group" do
      button_tag class: "pointer-item-add" do
        glyphicon("plus") + " add another"
      end
    end
  end

  view :list_item do |args|
    <<-HTML
      <li class="pointer-li">
        <span class="input-group">
          <span class="input-group-addon handle">
            #{glyphicon 'option-vertical left'}
    #{glyphicon 'option-vertical right'}
          </span>
          #{text_field_tag 'pointer_item', args[:pointer_item],
                           class: 'pointer-item-text form-control'}
          <span class="input-group-btn">
            <button class="pointer-item-delete btn btn-default" type="button">
              #{glyphicon 'remove'}
            </button>
          </span>
        </span>
      </li>
    HTML
  end

  view :checkbox do |_args|
    options = card.option_names.map do |option_name|
      checked = card.item_names.include?(option_name)
      id = "pointer-checkbox-#{option_name.to_name.key}"
      <<-HTML
        <div class="pointer-checkbox">
          #{check_box_tag 'pointer_checkbox', option_name, checked,
                          id: id, class: 'pointer-checkbox-button'}
          #{option_label option_name, id}
          #{option_description 'checkbox', option_name}
        </div>
      HTML
    end.join "\n"

    %(<div class="pointer-checkbox-list">#{options}</div>)
  end

  view :multiselect do |_args|
    select_tag(
      "pointer_multiselect",
      options_for_select(card.option_names, card.item_names),
      multiple: true, class: "pointer-multiselect form-control"
    )
  end

  view :radio do |_args|
    input_name = "pointer_radio_button-#{card.key}"
    options = card.option_names.map do |option_name|
      checked = (option_name == card.item_names.first)
      id = "pointer-radio-#{option_name.to_name.key}"
      <<-HTML
        <li class="pointer-radio radio">
          #{radio_button_tag input_name, option_name, checked,
                             id: id, class: 'pointer-radio-button'}
          #{option_label option_name, id}
          #{option_description 'radio', option_name}
        </li>
      HTML
    end.join("\n")

    %(<ul class="pointer-radio-list">#{options}</ul>)
  end

  def option_label option_name, id
    o_card = Card.fetch(option_name)
    label = (o_card && o_card.label) || option_name
    %(<label for="#{id}">#{label}</label>)
  end

  # @param option_type [String] "checkbox" or "radio"
  def option_description option_type, option_name
    return "" unless (description = pointer_option_description(option_name))
    %(<div class="#{option_type}-option-description">#{description}</div>)
  end

  view :select do |_args|
    options = [["-- Select --", ""]] + card.option_names.map { |x| [x, x] }
    select_tag("pointer_select",
               options_for_select(options, card.item_names.first),
               class: "pointer-select form-control")
  end

  def pointer_option_description option
    pod_name = card.rule(:options_label) || "description"
    dcard = Card["#{option}+#{pod_name}"]
    return unless dcard && dcard.ok?(:read)
    with_nest_mode :normal do
      subformat(dcard).render_core
    end
  end
end

def items= array
  self.content = ""
  array.each { |i| self << i }
  save!
end

def << item
  newname =
    case item
    when Card    then item.name
    when Integer then (c = Card[item]) && c.name
    else              item
    end
  add_item newname
end

def add_item name
  return if include_item? name
  self.content = "[[#{(item_names << name).reject(&:blank?) * "]]\n[["}]]"
end

def add_item! name
  add_item name
  save!
end

def drop_item name
  return unless include_item? name
  key = name.to_name.key
  new_names = item_names.reject { |n| n.to_name.key == key }
  self.content = new_names.empty? ? "" : "[[#{new_names * "]]\n[["}]]"
end

def drop_item! name
  drop_item name
  save!
end

def insert_item index, name
  new_names = item_names
  new_names.delete name
  new_names.insert index, name
  self.content = new_names.map { |new_name| "[[#{new_name}]]" }.join "\n"
end

def insert_item! index, name
  insert_item index, name
  save!
end

def option_names
  result_names =
    if (oc = options_rule_card)
      oc.item_names default_limit: 50, context: name
    else
      Card.search({ sort: "name", limit: 50, return: :name },
                  "option names for pointer: #{name}")
    end
  if (selected_options = item_names)
    result_names += selected_options
    result_names.uniq!
  end
  result_names
end

def option_cards
  option_names.map do |name|
    Card.fetch name, new: {}
  end
end
