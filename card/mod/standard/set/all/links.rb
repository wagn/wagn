RESOURCE_TYPE_REGEXP = /^([a-zA-Z][\-+\.a-zA-Z\d]*):/

format :html do
  def link_to pathish, text=nil, opts={}
    path = interpret_pathish pathish
    opts[:href] = path
    interpret_data_opts_to_link_to opts
    content_tag :a, raw(text || path), opts
  end

  def interpret_data_opts_to_link_to opts
    [:remote, :method].each do |key|
      next unless (val = opts.delete key)
      opts["data-#{key}"] = val
    end
  end
end

format :css do
  def link_to pathish, _text=nil, _opts={}
    card_url interpret_pathish(pathish)
  end
end

format do
  def link_to pathish, text=nil, _format_opts={}
    href = interpret_pathish pathish
    if text && href != text
      "#{text}[#{href}]"
    else
      href
    end
  end

  # link_to pathish, text, format_opts={}
  # link_to_card cardish, text=nil, opts={} # :path, :format
  # link_to_view view, text, opts={} # :path, :format
  # link_to_related cardish, text, opts={} # :path, :format, :related
  # link_to_resource resource, text, format_opts={}
  #
  # smart_link_to target, text, opts
  #
  # text, path_opts

  # link to url, view, card or related card

  def smart_link_to target, text=nil, format_opts={}
    target_type = [:view, :related, :card, :resource].find { |key| target[key] }
    method = "link_to_#{target_type}"
    target_value = target.delete target_type
    method_opts = format_opts.merge path: target
    send method, target_value, text, method_opts
  end

  def link_to_resource resource, text=nil, format_opts={}
    case (resource_type = resource_type resource)
    when "external-link" then format_opts[:target] = "_blank"
    when "internal-link" then resource = internal_url resource[1..-1]
    end
    add_class format_opts, resource_type
    link_to resource, text, format_opts
  end

  def resource_type resource
    case resource
    when /^https?\:/          then "external-link"
    when %r{^/}               then "internal-link"
    when /^mailto\:/          then "email-link"
    when RESOURCE_TYPE_REGEXP then Regexp.last_match(1) + "-link"
    end
  end

  def link_to_card cardish, text, opts={}
    name = Card::Name.cardish cardish
    text ||= name.to_name.to_show @context_names
    # @fixme - need smarter mark handling
    path_opts = (opts.delete(:path) || {}).merge name: name
    add_known_or_wanted_class opts, name
    link_to path_opts, text, opts
  end

  def add_known_or_wanted_class opts, name
    known = opts.delete :known
    known = Card.known?(name) if known.nil?
    add_class opts, (known ? "known-card" : "wanted-card")
  end

  # link to a specific view (defaults to current card)
  # this is generally used for ajax calls
  def link_to_view view, text, opts={}
    path_opts = opts.delete(:path) || {}
    path_opts[:view] = view unless view == :home
    format_opts = opts.merge remote: true, rel: "nofollow"
    link_to path_opts, text, format_opts
  end

  def link_to_related cardish, text=nil, opts={}
    name = Card::Name.cardish cardish
    opts[:path] ||= {}
    opts[:path][:related] ||= {}
    opts[:path][:related][:name] ||= "+#{name}"
    link_to_view :related, (text || name), opts
  end

  # @param opts [Hash]
  # @option opts [Symbol] :action card action (:create, :update, :delete)
  # @option opts [Integer, String] :id
  # @option opts [String, Card::Name] :name
  # @option opts [String] :type
  # @option opts [Hash] :card
  # @param mark_type [Symbol] defaults to :id
  def path opts={}, mark_type=:id
    base = new_cardtype_path(opts) || standard_path(opts, mark_type)
    query = path_query(opts)
    internal_url base + query
  end

  def new_cardtype_path opts
    return unless opts[:action] == :new
    opts.delete :action
    return unless opts[:type] && !opts[:name] && !opts[:card] && !opts[:id]
    "new/#{opts.delete :type}"
  end

  def standard_path opts, mark_type
    standardize_action! opts
    path_action(opts[:action]) + path_mark(opts, mark_type)
  end

  def path_action action
    case action
    when :create then "card/#{action}/"
    # sometimes create action has no mark,
    # but /create refers to a card named "create"
    when nil     then ""
    else              "#{action}/"
    end
  end

  def standardize_action! opts
    return if [:create, :update, :delete].member? opts[:action]
    opts.delete :action
  end

  def path_mark opts, mark_type
    case mark_type
    when :id       && (id = path_id opts)        then "~#{id}"
    when :codename && (codename = card.codename) then ":#{codename}"
    else (opts[:name] || card.name).to_name.url_key
    end
  end

  def path_id opts
    id = opts.delete :id
    id if id.present?
  end

  def path_query opts
    finalize_card_opts opts.delete(:card), opts
    opts.delete :action
    opts.empty? ? "" : "?#{opts.to_param}"
  end

  def finalize_card_opts card_opts, opts
    card_opts ||= {}
    [:name, :type].each do |field|
      assign_path_card_opt card_opts, field, opts
    end
    opts[:card] = card_opts unless card_opts.empty?
  end

  def assign_path_card_opt card_opts, field, opts
    optvalue = opts.delete field
    return if card_opts[field] || !optvalue.present?
    new_value = send "new_#{field}_in_path_opts", optvalue.to_s, opts
    return unless new_value
    card_opts[field] = new_value
  end

  def new_name_in_path_opts name, opts
    if opts[:action] == :update
      name if name != card.name
    elsif name != name.to_name.url_key
      name
    end
  end

  def new_type_in_path_opts opttype, _opts
    opttype if Card.known?(opttype)
  end

  def internal_url relative_path
    card_path relative_path
  end

  def interpret_pathish pathish
    pathish.is_a?(Hash) ? path(pathish) : pathish
  end
end


