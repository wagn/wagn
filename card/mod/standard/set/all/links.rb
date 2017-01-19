RESOURCE_TYPE_REGEXP = /^([a-zA-Z][\-+\.a-zA-Z\d]*):/

format :html do
  def link_to text=nil, opts={}
    opts[:href] ||= path opts.delete(:path)
    text = raw(text || opts[:href])
    interpret_data_opts_to_link_to opts
    wrap_with :a, text, opts
  end

  def interpret_data_opts_to_link_to opts
    [:remote, :method].each do |key|
      next unless (val = opts.delete key)
      opts["data-#{key}"] = val
    end
  end
end

format :css do
  def link_to _text=nil, opts={}
    card_url path(opts.delete(:path))
  end
end

format do
  def link_to text=nil, opts={}
    path = path opts.delete(:path)
    if text && path != text
      "#{text}[#{path}]"
    else
      path
    end
  end

  def link_to_resource resource, text=nil, opts={}
    case (resource_type = resource_type resource)
    when "external-link" then opts[:target] ||= "_blank"
    when "internal-link" then resource = internal_url resource[1..-1]
    end
    add_class opts, resource_type
    link_to text, opts.merge(path: resource)
  end

  def resource_type resource
    case resource
    when /^https?\:/          then "external-link"
    when %r{^/}               then "internal-link"
    when /^mailto\:/          then "email-link"
    when RESOURCE_TYPE_REGEXP then Regexp.last_match(1) + "-link"
    end
  end

  def link_to_card cardish, text=nil, opts={}
    opts[:path] ||= {}
    name = opts[:path][:mark] = Card::Name.cardish cardish
    text ||= name.to_name.to_show @context_names
    add_known_or_wanted_class opts, name
    link_to text, opts
  end

  def add_known_or_wanted_class opts, name
    known = opts.delete :known
    known = Card.known?(name) if known.nil?
    add_class opts, (known ? "known-card" : "wanted-card")
  end

  # dynamic (ajax) link to a specific view
  #
  def link_to_view view, text, opts={}
    opts.reverse_merge! path: {}, remote: true, rel: "nofollow"
    opts[:path][:view] = view unless view == :home
    link_to text, opts
  end

  def link_to_related cardish, text=nil, opts={}
    name = Card::Name.cardish cardish
    opts[:path] ||= {}
    opts[:path][:related] ||= {}
    opts[:path][:related][:name] ||= "+#{name}"
    link_to_view :related, (text || name), opts
  end

  # smart_link_to is wrapper method for #link_to, #link_to_card, #link_to_view,
  # #link_to_resource, and #link_to_related.  If the opts argument contains
  # :view, :related, :card, or :resource, it will use the respective method to
  # render a link.
  def smart_link_to text, opts={}
    if (linktype = [:view, :related, :card, :resource].find { |key| opts[key] })
      send "link_to_#{linktype}", opts.delete(linktype), text, opts
    else
      send :link_to, text, opts
    end
  end

  # path is for generating standard card routes, eg
  #   [cardname]
  #   [cardname]?[param]=[value]
  #   [action]/[cardname]?[param]=[value]

  # @param opts [Hash, String] a String is treated as a complete path and
  # bypasses all processing
  # @option opts [String, Card::Name, Integer, Symbol, Card] :mark
  # @option opts [Symbol] :action card action (:create, :update, :delete)
  # @option opts [Hash] :card
  # @option opts []
  def path opts={}
    return opts unless opts.is_a? Hash
    path = new_cardtype_path(opts) || standard_path(opts)
    internal_url path
  end

  def new_cardtype_path opts
    return unless opts[:action] == :new
    opts.delete :action
    return unless opts[:mark]
    "new/#{path_mark opts}#{path_query opts}"
  end

  def standard_path opts
    standardize_action! opts
    mark = path_mark opts
    base = path_base opts[:action], mark
    base + path_query(opts)
  end

  def path_base action, mark
    if action
      mark.present? ? "#{action}/#{mark}" : "card/#{action}"
      # the card/ prefix prevents interpreting action as cardname
    else
      mark
    end
  end

  def standardize_action! opts
    return if [:create, :update, :delete].member? opts[:action]
    opts.delete :action
  end

  def path_mark opts
    return "" if opts[:action] == :create || opts.delete(:no_mark)
    name = opts[:mark] ? Card::Name.cardish(opts.delete(:mark)) : card.name
    add_unknown_name_to_opts name.to_name, opts
    name.to_name.url_key
  end

  def path_query opts
    opts.delete :action
    opts.empty? ? "" : "?#{opts.to_param}"
  end

  def add_unknown_name_to_opts name, opts
    return if opts[:card] && opts[:card][:name]
    return if name.s == Card::Name.url_key_to_standard(name.url_key)
    return if Card.known? name
    opts[:card] ||= {}
    opts[:card][:name] = name
  end

  def internal_url relative_path
    card_path relative_path
  end
end
