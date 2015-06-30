
module ClassMethods
  def search spec
    query = ::Card::Query.new(spec)
    Card.with_logging :search, :message=>spec, :details=>query.sql.strip do
      results = query.run
      if block_given? and Array===results
        results.each { |result| yield result }
      end
      results
    end
  end

  def count_by_wql(spec)
    spec = spec.clone
    spec.delete(:offset)
    search spec.merge(:return=>'count')
  end

  def find_each(options = {})
    #this is a copy from rails (3.2.16) and is needed because this is performed by a relation (ActiveRecord::Relation)
    find_in_batches(options) do |records|
      records.each { |record| yield record }
    end
  end

  def find_in_batches(options = {})
    if block_given?
      super(options) do |records|
        yield(records)
        Card::Cache.reset_global
      end
    else
      super(options)
    end
  end
end

def item_names(args={})
  format._render_raw.split /[,\n]/
end

def item_cards(args={})  ## FIXME this is inconsistent with item_names
  [self]
end

def item_type
  nil
end

def include_item? item
  key = if Card === item
    item.cardname.key
  else
    item.to_name.key
  end
  item_names.map{|name| name.to_name.key}.member? key
end

def add_item item
  unless include_item? item
    self.content="#{self.content}\n#{name}"
  end
end

def drop_item item
  if include_item? item
    new_names = item_names.reject{ |i| i == item }
    self.content = new_names.empty? ? '' : new_names.join("\n")
  end
end

def insert_item index, name
  new_names = item_names
  new_names.delete(name)
  new_names.insert(index,name)
  self.content =  new_names.join "\n"
end


def extended_item_cards context = nil
  context = (context ? context.cardname : self.cardname)
  args={ :limit=>'' }
  items = self.item_cards(args.merge(:context=>context))
  extended_list = []
  already_extended = ::Set.new # avoid loops

  while items.size > 0
    item = items.shift
    if already_extended.include? item
      next
    elsif item.item_cards == [item]  # no further level of items
      extended_list << item
      already_extended << item
    else
      items.unshift(*item.item_cards) # keep items in order
      already_extended << item
    end
  end
  extended_list
end

def extended_item_contents context = nil
  extended_item_cards(context).map(&:item_names).flatten
end

def extended_list context = nil
  context = (context ? context.cardname : self.cardname)
  args={ :limit=>'' }
  self.item_cards(args.merge(:context=>context)).map do |x|
    x.item_cards(args)
  end.flatten.map do |x|
    x.item_cards(args)
  end.flatten.map do |y|
    y.item_names(args)
  end.flatten
  # this could go on and on.  more elegant to recurse until you don't have a collection
end

def contextual_content context_card, format_args={}, view_args={}
  context_card.format(format_args).process_content(
    self.format(format_args)._render_raw(view_args), view_args
  )
end

format do

  def item_links(args={})
    raw(render_core).split /[,\n]/
  end

  def item_view args
    args[:item] || (@inclusion_opts && @inclusion_opts[:view]) || default_item_view
  end

  def item_args args
    i_args = { :view => item_view(args)}
    if type = card.item_type
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
      p = { :default_limit=> 100 }.merge overrides
      set_search_params_variables! p
      p
    end
  end

  def set_search_params_variables! hash
    hash[:vars] = params[:vars] || {}
    params.each do |key,val|
      case key.to_s
      when '_wql'      ;  hash.merge! val
      when /^\_(\w+)$/ ;  hash[:vars][$1.to_sym] = val
      end
    end
  end


  def each_reference_with_args args={}
    Card::Content.new(render_raw, card).find_chunks( Card::Chunk::Reference ).each do |chunk|
      yield(chunk.referee_name.to_s, nest_args(args,chunk))
    end
  end


  def each_nested_chunk
    Card::Content.new(render_raw, card).find_chunks( Card::Chunk::Include).each do |chunk|
      yield(chunk) if chunk.referee_name # filter commented nests
    end
  end

  def has_nested_fields?
    nested_fields.present?
  end

  def nested_fields
    @nested_fields = begin
      result = []
      each_nested_field do |chunk|
        result << chunk
      end
      result
    end
  end

  def unique_chunks chunk, processed_set, &block
    if !processed_set.include? chunk.referee_name.key
      processed_set << chunk.referee_name.key
      block.call(chunk)
    end
  end

  def each_nested_field &block
    processed_chunk_keys = ::Set.new([card.key])

    each_nested_chunk do |chunk|
      # TODO handle structures that are non-virtual
      if chunk.referee_name.to_name.is_a_field_of? card.name
        if chunk.referee_card && chunk.referee_card.virtual?
          subformat(chunk.referee_card).each_nested_field do |sub_chunk|
            unique_chunks sub_chunk, processed_chunk_keys, &block
          end
        else
          unique_chunks chunk, processed_chunk_keys, &block
        end
      end
    end

  end

  def map_references_with_args args={}, &block
    result = []
    each_reference_with_args args do |name, n_args|
      result << block.call(name, n_args)
    end
    result
  end

  # process args for links and nests
  def nest_args args, chunk=nil
    r_args = item_args(args)
    if @inclusion_opts
      r_args.merge! @inclusion_opts.clone
    end
    if chunk.kind_of? Card::Chunk::Include
      r_args.merge!(chunk.options)
    elsif chunk.kind_of? Card::Chunk::Link
      r_args.reverse_merge!(:view=>:link)
      r_args.reverse_merge!(:title=>chunk.link_text) if chunk.link_text
    end
    r_args
  end

end


format :html do
  view :tabs do |args|
    tab_buttons = ''
    tab_panes = ''
    active_tab = true
    each_reference_with_args(:item=>:content) do |name, nest_args|
      id         = "#{card.cardname.safe_key}-#{name.to_name.safe_key}"
      url        = nest_path name, nest_args
      tab_name   = nest_args[:title] || name
      tab_buttons += tab_button( "##{id}", tab_name, active_tab, 'data-url'=>url.html_safe, :class=>(active_tab ? nil : 'load'))

      # only render the first active tab, other tabs get loaded via ajax
      tab_content = active_tab ? nest(Card.fetch(name, :new=>{}), nest_args) : ''
      tab_panes += tab_pane( id, tab_content, active_tab )
      active_tab = false
    end
    tab_panel tab_buttons, tab_panes, args[:tab_type]
  end
  def default_tabs_args args
    args[:tab_type] ||= 'tabs'
  end


  # create a path for a nest with respect ot the inclusion options
  def nest_path name, nest_args
    path_args = {}
    path_args[:view] = nest_args[:view]
    path_args[:slot] = nest_args.clone
    path_args[:slot].delete(:view)
    page_path(name, path_args)
  end

  view :pills, :view=>:tabs
  def default_pills_args args
    args[:tab_type] ||= 'pills'
  end

  view :tabs_static do |args|
    tab_buttons = ''
    tab_panes = ''
    card.item_cards.each_with_index do |item, index|
      id = "#{card.cardname.safe_key}-#{item.cardname.safe_key}"
      tab_buttons += tab_button( "##{id}", item.name, index == 0 )
      tab_content = nest item, item_args(args)
      tab_panes += tab_pane( id, tab_content, index == 0 )
    end
    tab_panel tab_buttons, tab_panes, args[:tab_type]
  end
  def default_tabs_static_args args
    args[:tab_type] ||= 'tabs'
  end

  view :pills_static, :view=>:tabs
  def default_tabs_static_args args
    args[:tab_type] ||= 'pills'
  end

  def tab_panel tab_buttons, tab_panes, tab_type='tabs'
    wrap_with :div, :role=>"tabpanel" do
      [
        content_tag(:ul, tab_buttons.html_safe, :class=>"nav nav-#{tab_type}", :role=>"tablist"),
        content_tag(:div, tab_panes.html_safe, :class=>'tab-content')
      ]
    end
  end

  def tab_button target, text, active=false, link_attr={}
    link = link_to fancy_title(text), target, link_attr.merge('role'=>'tab','data-toggle'=>'tab')
    li_args = { :role => :presentation }
    li_args[:class] = 'active' if active
    content_tag :li, link, li_args
  end

  def tab_pane id, content, active=false
    div_args = {:role => :tabpanel, :id=>id, :class=>"tab-pane #{'active' if active}"}
    content_tag :div, content.html_safe, div_args
  end
end

