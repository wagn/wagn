stage_method :changed_item_names do
  dropped_item_names + added_item_names
end

stage_method :dropped_item_names do
  old_items = item_names content: db_content_was
  old_items - item_names
end

stage_method :added_item_names do
  old_items = item_names content: db_content_was
  item_names - old_items
end

format do
  def item_links args={}
    card.item_cards(args).map do |item_card|
      subformat(item_card).render_link
    end
  end

  def wrap_item item, _args={}
    item # no wrap in base
  end

  view :core do |args|
    render_pointer_items args.merge(joint: ", ")
  end

  view :pointer_items, tags: :unknown_ok do |args|
    i_args = item_args(args)
    joint = args[:joint] || " "
    card.item_cards.map do |i_card|
      wrap_item nest(i_card, i_args.clone), i_args
    end.join joint
  end
end

format :html do
  view :core do |args|
    %(<div class="pointer-list">#{render_pointer_items args}</div>)
  end

  view :closed_content do |args|
    args[:item] =
      if (args[:item] || nest_defaults(card)[:view]) == "name"
        "name"
      else
        "link"
      end
    args[:joint] ||= ", "
    _render_core args
  end

  def wrap_item item, args
    %(<div class="pointer-item item-#{args[:view]}">#{item}</div>)
  end
end

format :css do
  # generalize to all collections?
  def default_item_view
    params[:item] || :content
  end

  view :titled do |_args|
    %(#{major_comment "STYLE GROUP: \"#{card.name}\"", '='}#{_render_core})
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
      nest item, view: (args[:item] || :core)
    end.join "\n\n"
  end
end

format :data do
  view :core do |_args|
    card.item_cards.map do |c|
      nest c
    end
  end
end

format :rss do
  def raw_feed_items _args
    @raw_feed_items ||= begin
      card.item_cards
    end
  end
end

format :json do
  view :export_items do |args|
    result =
      card.known_item_cards.map do |ic|
        subformat(ic).render_export(args)
      end
    result.flatten.reject(&:blank?)
  end
end

# while a card's card type and content are updated in the same request,
# the new module will override the old module's events and functions.
# this event is only on pointer card. Other type cards do not have this event,
# so it is not overridden and will be run while updating type and content in
# the same request.
event :standardize_items, :prepare_to_validate,
      on: :save,
      changed: :content,
      when: proc { |c| c.type_id == Card::PointerID  } do
  self.content = item_names(context: :raw).map do |name|
    "[[#{name}]]"
  end.join "\n"
end

def diff_args
  { format: :pointer }
end

def item_cards args={}
  if args[:complete]
    query = args.reverse_merge referred_to_by: name
    Card::Query.run query
  elsif args[:known_only]
    known_item_cards args
  else
    fetch_or_initialize_item_cards args
  end
end

def known_item_cards args={}
  item_names(args).map do |name|
    Card.fetch name
  end.compact
end

def fetch_or_initialize_item_cards args
  itype = args[:type] || item_type
  new_args = itype ? { type: itype } : {}
  item_names(args).map do |name|
    Card.fetch name, new: new_args
  end
end

def item_names args={}
  context = args[:context] || cardname
  content = args[:content] || raw_content
  content.to_s.split(/\n+/).map do |line|
    item_name = line.gsub(/\[\[|\]\]/, "").strip
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
  if !opt || opt == self # fixme, need better recursion prevention
    nil
  else
    opt.item_type
  end
end

def options_rule_card
  rule_card :options
end
