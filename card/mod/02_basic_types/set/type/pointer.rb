

event :add_and_drop_items, before: :approve, on: :save do
  adds = Env.params['add_item']
  drops = Env.params['drop_item']
  Array.wrap(adds).each { |i| add_item i } if adds
  Array.wrap(drops).each { |i| drop_item i } if drops
end

event :insert_item_event, before: :approve, on: :save, when: proc {|c| Env.params['insert_item']} do
  index = Env.params['item_index'] || 0
  self.insert_item index.to_i, Env.params['insert_item']
end

phase_method :changed_item_names do
  dropped_item_names + added_item_names
end

phase_method :dropped_item_names do
  old_items = item_names content: db_content_was
  old_items - item_names
end

phase_method :added_item_names do
  old_items = item_names content: db_content_was
  item_names - old_items
end

format do
  def item_links args={}
    card.item_cards(args).map do |item_card|
      subformat(item_card).render_link
    end
  end

  def wrap_item item, args={}
    item #no wrap in base
  end

  view :core do |args|
    render_pointer_items args.merge(joint: ', ')
  end

  view :pointer_items, tags: :unknown_ok do |args|
    i_args = item_args(args)
    joint = args[:joint] || ' '
    card.item_cards.map do |i_card|
      wrap_item nest(i_card, i_args.clone), i_args
    end.join joint
  end
end

format :html do

  view :core do |args|
    %{<div class="pointer-list">#{ render_pointer_items args }</div>}
  end

  view :closed_content do |args|
    args[:item] = (args[:item] || inclusion_defaults(card)[:view])=='name' ? 'name' : 'link'
    args[:joint] ||= ', '
    _render_core args
  end

#  view :edit do |args|
#    super(args.merge(pointer_item_class: 'form-control'))
#  end

  view :editor do |args|
    part_view = (c = card.rule(:input)) ? c.gsub(/[\[\]]/,'') : :list
    hidden_field( :content, class: 'card-content') +
    raw(_render part_view, args)

    #.merge(pointer_item_class: 'form-control')))
  end

  view :list do |args|
    args ||= {}
    items = args[:item_list] || card.item_names(context: :raw)
    items = [''] if items.empty?
    options_card_name = (oc = card.options_rule_card) ? oc.cardname.url_key : ':all'

    extra_css_class = args[:extra_css_class] || 'pointer-list-ul'

    <<-HTML
      <ul class="pointer-list-editor #{extra_css_class}" data-options-card="#{options_card_name}">
        #{
          items.map do |item|
            _render_list_item args.merge( pointer_item: item )
          end * "\n"
        }
      </ul>
      #{ add_item_button }
    HTML
  end

  def add_item_button
    content_tag :span, class: 'input-group' do
      button_tag class: 'pointer-item-add' do
        glyphicon('plus') + ' add another'
      end
    end
  end

  view :list_item do |args|
   <<-HTML
    <li class="pointer-li">
      <span class="input-group">
        <span class="input-group-addon handle">
          #{ glyphicon 'option-vertical left' }
          #{ glyphicon 'option-vertical right'}
        </span>
        #{ text_field_tag 'pointer_item', args[:pointer_item], class: 'pointer-item-text form-control' }
        <span class="input-group-btn">
          <button class="pointer-item-delete btn btn-default" type="button">
            #{ glyphicon 'remove'}
          </button>
        </span>
        </span>
      </li>
    HTML
  end


  view :checkbox do |args|
    options = card.option_names.map do |option_name|
      checked = card.item_names.include?(option_name)
      label = ((o_card = Card.fetch(option_name)) && o_card.label) || option_name
      id = "pointer-checkbox-#{option_name.to_name.key}"
      description = pointer_option_description option_name
      <<-HTML
        <div class="pointer-checkbox">
          #{ check_box_tag "pointer_checkbox", option_name, checked, id: id, class: 'pointer-checkbox-button' }
          <label for="#{id}">#{label}</label>
          #{ %{<div class="checkbox-option-description">#{ description }</div>} if description }
        </div>
      HTML
    end.join "\n"

    %{<div class="pointer-checkbox-list">#{options}</div>}
  end

  view :multiselect do |args|
    select_tag("pointer_multiselect",
      options_for_select(card.option_names, card.item_names),
      multiple: true, class: 'pointer-multiselect form-control'
    )
  end

  view :radio do |args|
    input_name = "pointer_radio_button-#{card.key}"
    options = card.option_names.map do |option_name|
      checked = (option_name==card.item_names.first)
      id = "pointer-radio-#{option_name.to_name.key}"
      label = ((o_card = Card.fetch(option_name)) && o_card.label) || option_name
      description = pointer_option_description option_name
      <<-HTML
        <li class="pointer-radio radio">
          #{ radio_button_tag input_name, option_name, checked, id: id, class: 'pointer-radio-button' }
          <label for="#{id}">#{ label }</label>
          #{ %{<div class="radio-option-description">#{ description }</div>} if description }
        </li>
      HTML
    end.join("\n")

    %{<ul class="pointer-radio-list">#{options}</ul>}
  end

  view :select do |args|
    options = [["-- Select --",""]] + card.option_names.map{ |x| [x,x]}
    select_tag("pointer_select",
      options_for_select(options, card.item_names.first),
      class: 'pointer-select form-control'
    )
  end


  def pointer_option_description option
    pod_name = card.rule(:options_label) || 'description'
    dcard = Card[ "#{option}+#{pod_name}" ]
    if dcard and dcard.ok? :read
      with_inclusion_mode :normal do
        subformat(dcard).render_core
      end
    end
  end



  def wrap_item item, args
    %{<div class="pointer-item item-#{args[:view]}">#{item}</div>}
  end


end


format :css do

  #generalize to all collections?
  def default_item_view
    params[:item] || :content
  end

  view :titled do |args|
    %(#{major_comment "STYLE GROUP: \"#{card.name}\"", '='}#{ _render_core })
  end

  view :core do |args|
    card.item_cards.map do |item|
      nest item, view: item_view(args)
    end.join "\n\n"
  end

  view :content, :core

end


format :js do

  view :core do |args|
    card.item_cards.map do |item|
      nest item, view: ( args[:item] || :core)
    end.join "\n\n"
  end
end


format :data do
  view :core do |args|
    card.item_cards.map do |c|
      nest c
    end
  end
end

format :rss do
  def raw_feed_items args
    @raw_feed_items ||= begin
      card.item_cards
    end
  end
end

# while a card's card type and content are updated in the same request,
# the new module will override the old module's events and functions.
# this event is only on pointer card. Other type cards do not have this event,
# so it is not overridden and will be run while updating type and content in the same request.
event :standardize_items, before: :approve, on: :save, changed: :content,
    when: proc{  |c| c.type_id == Card::PointerID  } do
    self.content = item_names(context: :raw).map { |name| "[[#{name}]]" }.join "\n"
end



def diff_args
  {format: :pointer}
end

def item_cards args={}
  if args[:complete]
    query = { referred_to_by: name }.merge args
    Card::Query.run query
  else

    itype = args[:type] || item_type
    #warn "item_card[#{inspect}], :complete"
    item_names(args).map do |name|
      new_args = itype ? { type: itype } : {}
      Card.fetch name, new: new_args
    end.compact # compact?  can't be nil, right?
  end
end


def item_names args={}
  context = args[:context] || self.cardname
  content = args[:content] || self.raw_content
  content.to_s.split(/\n+/).map do |line|
    item_name = line.gsub( /\[\[|\]\]/, '').strip
    if context == :raw
      item_name
    else
      item_name.to_name.to_absolute context
    end
  end
end


def item_ids args={}
  item_names(args).map do |name|
    Card.fetch_id name
  end.compact
end

def item_type
  opt = options_rule_card
  if !opt or opt==self #fixme, need better recursion prevention
    nil
  else
    opt.item_type
  end
end

def items= array
  self.content = ''
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
  self.content = new_names.empty? ? '' : "[[#{new_names * "]]\n[["}]]"
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

def options_rule_card
  rule_card :options
end

def option_names
  result_names =
    if (oc = options_rule_card)
      oc.item_names default_limit: 50, context: name
    else
      Card.search({ sort: 'name', limit: 50, return: :name },
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
