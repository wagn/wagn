# shared methods for card collections (Pointers, Searches, Sets, etc.)
module ClassMethods
  def search spec, comment=nil
    results = ::Card::Query.run(spec, comment)
    if block_given? && results.is_a?(Array)
      results.each { |result| yield result }
    end
    results
  end

  def count_by_wql spec
    spec = spec.clone
    spec.delete(:offset)
    search spec.merge(return: "count")
  end

  def find_each options={}
    # this is a copy from rails (3.2.16) and is needed because this
    # is performed by a relation (ActiveRecord::Relation)
    find_in_batches(options) do |records|
      records.each { |record| yield record }
    end
  end

  def find_in_batches options={}
    if block_given?
      super(options) do |records|
        yield(records)
        Card::Cache.reset_soft
      end
    else
      super(options)
    end
  end
end

def item_names _args={}
  format._render_raw.split(/[,\n]/)
end

def item_cards _args={} # FIXME: this is inconsistent with item_names
  [self]
end

def collection?
  item_cards != [self]
end

def item_type
  nil
end

def item_keys args={}
  item_names(args).map do |item|
    item.to_name.key
  end
end

def include_item? item
  key = item.is_a?(Card) ? item.cardname.key : item.to_name.key
  item_names.map { |name| name.to_name.key }.member? key
end

def add_item item
  return if include_item? item
  self.content = "#{content}\n#{name}"
end

def drop_item item
  return unless include_item? item
  new_names = item_names.reject { |i| i == item }
  self.content = new_names.empty? ? "" : new_names.join("\n")
end

def insert_item index, name
  new_names = item_names
  new_names.delete name
  new_names.insert index, name
  self.content = new_names.join "\n"
end

def add_id id
  add_item "~#{id}"
end

def drop_id id
  drop_item "~#{id}"
end

def insert_id index, id
  insert_item index, "~#{id}"
end

def extended_item_cards context=nil
  context = (context ? context.cardname : cardname)
  args = { limit: "" }
  items = item_cards(args.merge(context: context))
  extended_list = []
  already_extended = ::Set.new # avoid loops

  until items.empty?
    item = items.shift
    next if already_extended.include? item
    already_extended << item
    if item.collection?
      # keep items in order
      items.unshift(*item.item_cards)
    else  # no further level of items
      extended_list << item
    end
  end
  extended_list
end

def extended_item_contents context=nil
  extended_item_cards(context).map(&:item_names).flatten
end

def extended_list context=nil
  context = (context ? context.cardname : cardname)
  args = { limit: "" }
  item_cards(args.merge(context: context)).map do |x|
    x.item_cards(args)
  end.flatten.map do |x|
    x.item_cards(args)
  end.flatten.map do |y|
    y.item_names(args)
  end.flatten
  # this could go on and on.  more elegant to recurse until you don't have
  # a collection
end

def context_card
  @context_card || self
end

def with_context card
  old_context = @context_card
  @context_card = card if card
  result = yield
  @context_card = old_context
  result
end

def contextual_content context_card, format_args={}, view_args={}
  view = view_args.delete(:view) || :core
  with_context context_card do
    format(format_args).render view, view_args
  end
end

def each_chunk opts={}
  content = opts[:content] || raw_content
  chunk_type = opts[:chunk_type] || Card::Content::Chunk
  Card::Content.new(content, self).find_chunks(chunk_type).each do |chunk|
    next unless chunk.referee_name # filter commented nests
    yield chunk
  end
end

def each_reference_chunk content=nil
  reference_chunk_type = Card::Content::Chunk::Reference
  each_chunk content: content, chunk_type: reference_chunk_type do |chunk|
    yield chunk
  end
end

def each_nested_chunk content=nil
  nest_chunk_type = Card::Content::Chunk::Nest
  each_chunk content: content, chunk_type: nest_chunk_type do |chunk|
    yield chunk
  end
end

def each_item_name_with_options content=nil
  each_reference_chunk content do |chunk|
    options = chunk.respond_to?(:options) ? chunk.options : {}
    yield chunk.referee_name, options
  end
end

format do
  def item_links _args={}
    raw(render_core).split(/[,\n]/)
  end

  def nest_item cardish, options={}, &block
    options = item_view_options options
    options[:nest_name] = Card::Name.cardish(cardish).s
    nest cardish, options, &block
  end

  def implicit_item_view
    view = voo_items_view || default_item_view
    Card::View.canonicalize view
  end

  def voo_items_view
    return unless voo && (items = voo.items)
    items[:view]
  end

  def default_item_view
    :name
  end

  def item_view_options new_options={}
    options = (voo.items || {}).clone
    options = options.merge new_options
    options[:view] ||= implicit_item_view
    determine_item_view_options_type options
    options
  end

  def determine_item_view_options_type options
    return if options[:type]
    type_from_rule = card.item_type
    options[:type] = type_from_rule if type_from_rule
  end

  def nested_fields content=nil
    result = []
    each_nested_field(content) do |chunk|
      result << [chunk.referee_name, chunk.options]
    end
    result
  end

  def nested_fields_for_edit
    return normalized_edit_fields if edit_fields.present?
    result = []
    each_nested_field do |chunk|
      result << [chunk.options[:nest_name], chunk.options]
    end
    result
  end

  def edit_fields
    voo.edit_structure || []
  end

  def normalized_edit_fields
    edit_fields.map do |name_or_card, options|
      next [name_or_card, options || {}] if name_or_card.is_a?(Card)
      options ||= Card.fetch_name name_or_card
      options = { title: options } if options.is_a?(String)
      [card.cardname.field(name_or_card), options]
    end
  end

  def process_field chunk, processed, &_block
    return unless process_unique_field? chunk, processed
    yield chunk
  end

  def each_nested_field content=nil, &block
    processed = ::Set.new [card.key]
    content ||= _render_raw
    card.each_nested_chunk content do |chunk|
      next unless chunk.referee_name.to_name.field_of? card.name
      process_nested_chunk chunk, processed, &block
    end
  end

  def process_nested_chunk chunk, processed, &block
    virtual = chunk.referee_card && chunk.referee_card.virtual?
    # TODO: handle structures that are non-virtual
    method = virtual ? :process_virtual_field : :process_field
    send method, chunk, processed, &block
  end

  def process_virtual_field chunk, processed, &block
    return unless process_unique_field? chunk, processed
    subformat(chunk.referee_card).each_nested_field do |sub_chunk|
      process_field sub_chunk, processed, &block
    end
  end

  def process_unique_field? chunk, processed
    key = chunk.referee_name.key
    return false if processed.include? key
    processed << key
    true
  end
end

format :html do
  view :count do |args|
    card.item_names(args).size
  end

  view :tabs do
    construct_tabs "tabs"
  end

  def construct_tabs tab_type
    tabs = { active: {}, paths: {} }
    voo.items[:view] ||= :content
    card.each_item_name_with_options(_render_raw) do |name, options|
      construct_tab tabs, name, options
    end
    lazy_loading_tabs tabs[:paths], tabs[:active][:name],
                      tabs[:active][:content], type: tab_type
  end

  def construct_tab tabs, name, explicit_options
    tab_options = item_view_options explicit_options
    title = tab_title tab_options[:title], name
    tabs[:paths][title] = { title: title,
                            path: nest_path(name, tab_options).html_safe }
    return unless tabs[:active].empty?
    tabs[:active] = { name: title, content: nest(name, tab_options) }
  end

  def tab_title title, name
    return name unless title
    name.to_name.title title, @context_names
  end

  # create a path for a nest with respect ot the nest options
  def nest_path name, nest_opts={}
    path_opts = { slot: nest_opts.clone }
    path_opts[:view] = path_opts[:slot].delete :view
    page_path name, path_opts
  end

  view :pills do
    construct_tabs "pills"
  end

  view :tabs_static do
    construct_static_tabs "tabs"
  end

  view :pills_static do
    construct_static_tabs "pills"
  end

  def construct_static_tabs tab_type
    tabs = {}
    card.item_cards.each do |item|
      tabs[item.name] = nest item, item_view_options(args)
    end
    static_tabs tabs, tab_type
  end
end
