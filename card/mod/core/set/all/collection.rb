
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

def contextual_content context_card, format_args={}, view_args={}
  context_card.format(format_args).process_content(
    format(format_args)._render_raw(view_args), view_args
  )
end

format do
  def item_links _args={}
    raw(render_core).split(/[,\n]/)
  end

  def item_view args
    args[:item] ||
      (@nest_opts && @nest_opts[:view]) ||
      default_item_view
  end

  def item_args args
    i_args = { view: item_view(args) }
    if (type = card.item_type)
      i_args[:type] = type
    end
    i_args
  end

  def search_params
    @search_params ||= begin
      p = default_search_params.clone

      if focal?
        p[:offset] = params[:offset] if params[:offset]
        p[:limit]  = params[:limit]  if params[:limit]
        p.merge! params[:wql]        if params[:wql]
      end
      p
    end
  end

  def default_search_params # wahh?
    set_default_search_params
  end

  def set_default_search_params overrides={}
    @default_search_params ||= begin
      p = { default_limit: 100 }.merge overrides
      set_search_params_variables! p
      p
    end
  end

  def set_search_params_variables! hash
    hash[:vars] = params[:vars] || {}
    params.each do |key, val|
      case key.to_s
      when "_wql"      then hash.merge! val
      when /^\_(\w+)$/ then hash[:vars][Regexp.last_match(1).to_sym] = val
      end
    end
  end

  def each_reference_with_args args={}
    content_object = Card::Content.new _render_raw(args), card
    content_object.find_chunks(Card::Content::Chunk::Reference).each do |chunk|
      yield chunk.referee_name.to_s, nest_args(args, chunk)
    end
  end

  def each_nested_chunk args={}
    content_object = Card::Content.new(_render_raw(args), card)
    content_object.find_chunks(Card::Content::Chunk::Include).each do |chunk|
      yield(chunk) if chunk.referee_name # filter commented nests
    end
  end

  def nested_fields args={}
    result = []
    each_nested_field(args) do |chunk|
      result << chunk
    end
    result
  end

  def unique_chunks chunk, processed_set, &_block
    return if processed_set.include? chunk.referee_name.key
    processed_set << chunk.referee_name.key
    yield(chunk)
  end

  def each_nested_field args, &block
    processed_chunk_keys = ::Set.new([card.key])

    each_nested_chunk(args) do |chunk|
      # TODO: handle structures that are non-virtual
      next unless chunk.referee_name.to_name.field_of? card.name
      if chunk.referee_card &&
         chunk.referee_card.virtual? &&
         !processed_chunk_keys.include?(chunk.referee_name.key)

        processed_chunk_keys << chunk.referee_name.key
        subformat(chunk.referee_card).each_nested_field(args) do |sub_chunk|
          unique_chunks sub_chunk, processed_chunk_keys, &block
        end
      else
        unique_chunks chunk, processed_chunk_keys, &block
      end
    end
  end

  def map_references_with_args args={}, &_block
    result = []
    each_reference_with_args args do |name, n_args|
      result << yield(name, n_args)
    end
    result
  end

  # process args for links and nests
  def nest_args args, chunk=nil
    r_args = item_args(args)
    r_args.merge! @nest_opts.clone if @nest_opts

    case chunk
    when Card::Content::Chunk::Include
      r_args.merge!(chunk.options)
    when Card::Content::Chunk::Link
      r_args.reverse_merge!(view: :link)
      r_args.reverse_merge!(title: chunk.link_text) if chunk.link_text
    end
    r_args
  end
end

format :html do
  view :count do |args|
    card.item_names(args).size
  end

  view :tabs do |args|
    active_name = nil
    active_content = nil
    tabs = {}
    each_reference_with_args(item: :content) do |name, nest_args|
      tab_name = nest_args[:title] || name
      tabs[tab_name] = nest_path(name, nest_args).html_safe

      active_name ||= tab_name
      # warning: nest changes nest_args
      active_content ||= nest(Card.fetch(name, new: {}), nest_args)
    end
    lazy_loading_tabs tabs, active_name, active_content,
                      type: args[:tab_type]
  end
  def default_tabs_args args
    args[:tab_type] ||= "tabs"
  end

  # create a path for a nest with respect ot the nest options
  def nest_path name, nest_args
    path_args = {}
    path_args[:view] = nest_args[:view]
    path_args[:slot] = nest_args.clone
    path_args[:slot].delete(:view)
    page_path(name, path_args)
  end

  view :pills, view: :tabs
  def default_pills_args args
    args[:tab_type] ||= "pills"
  end

  view :tabs_static do |args|
    tabs = {}
    card.item_cards.each do |item|
      tabs[item.name] = nest item, item_args(args)
    end
    static_tabs tabs, args[:tab_type]
  end
  def default_tabs_static_args args
    args[:tab_type] ||= "tabs"
  end

  view :pills_static, view: :tabs_static
  def default_tabs_static_args args
    args[:tab_type] ||= "pills"
  end
end
