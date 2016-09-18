RESOURCE_TYPE_REGEXP = /^([a-zA-Z][\-+\.a-zA-Z\d]*):/

format do
  # link is called by web_link, card_link, and view_link
  # (and is overridden in other formats)
  def link_to text, pathish, _opts={}
    href = interpret_pathish pathish

    if text && href != text
      "#{text}[#{href}]"
    else
      href
    end
  end

  link_to pathish, text, _opts={}
  link_to_card cardish
  link_to_view view, text,
  link_to_related
  link_to_resource resource, text,


  text, path_opts

  # link to url, view, card or related card
  def smart_link link_text, target, html_args={}
    if (view = target.delete(:view))
      view_link link_text, view, html_args.merge(path_opts: target)
    elsif (page = target.delete(:card))
      card_link page, html_args.merge(path_opts: target, text: link_text)
    elsif target[:related]
      if target[:related].is_a? String
        target[:related] = { name: "+#{target[:related]}" }
      end
      view_link link_text, :related, html_args.merge(path_opts: target)
    elsif target[:web]
    else
      link_to link_text, target, html_args
    end
  end

  # link to a specific url or path
  def web_link href, opts={}
    text = opts.delete(:text) || href
    new_class =
      case href
      when /^https?\:/
        opts[:target] = "_blank"
        "external-link"
      when %r{^/}
        href = internal_url href[1..-1]
        "internal-link"
      when /^mailto\:/                    then "email-link"
      when  then Regexp.last_match(1) + "-link"
      else                                return card_link href, opts
      end
    add_class opts, new_class
    link_to text, href, opts
  end



  def link_to_resource resource, text, opts={}
    text ||= resource
    resource_type = resource_type resource
    case (resource_type = resource_type resource)
    when "external-link" then opts[:target] = "_blank"
    when "internal-link" then resource = internal_url resource[1..-1]
    end
    add_class opts, resource_type
    link_to text, resource, opts
  end

  def resource_type resource
    case resource
    when /^https?\:/          then "external-link"
    when %r{^/}               then "internal-link"
    when /^mailto\:/          then "email-link"
    when RESOURCE_TYPE_REGEXP then Regexp.last_match(1) + "-link"
    end
  end

  # link to a specific card
  def card_link cardish, opts={}
    name = Card::Name.cardish cardish
    text = (opts.delete(:text) || name).to_name.to_show @context_names

    path_opts = opts.delete(:path_opts) || {}
    path_opts[:name] = name
    known = opts[:known].nil? ? Card.known?(name) : opts.delete(:known)
    add_class opts, (known ? "known-card" : "wanted-card")
    link_to text, path_opts, opts
  end

  # link to a specific view (defaults to current card)
  # this is generally used for ajax calls
  def view_link text, view, opts={}
    path_opts = opts.delete(:path_opts) || {}
    path_opts[:view] = view unless view == :home
    opts[:remote] = true
    opts[:rel] = "nofollow"

    link_to text, path_opts, opts
  end

  def related_link cardish, opts={}
    name = Card::Name.cardish cardish
    opts[:path_opts] ||= { view: :related }
    opts[:path_opts][:related] = { name: "+#{name}" }
    opts[:path_opts][:related].merge! opts[:related_opts] if opts[:related_opts]
    view_link(opts[:text] || name, :related, opts)
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
    return if card_opts[field]
    new_value = send "new_#{field}_in_path_opts", optvalue, opts
    return unless new_value
    card_opts[field] = new_value
  end

  def new_name_in_path_opts optname, opts
    name = (optname || card.name).to_s
    if opts[:action] == :update
      optname if optname != name
    elsif name != name.to_name.url_key
      name
    end
  end

  def new_type_in_path_opts opttype, _opts
    opttype if opttype && Card.known?(opttype)
  end

  def internal_url relative_path
    card_path relative_path
  end

  def interpret_pathish pathish
    pathish.is_a?(Hash) ? path(pathish) : pathish
  end
end

format :html do
  def link_to text, href, opts={}
    opts[:href] = interpret_pathish href
    data_option_for_link_to :remote, opts
    data_option_for_link_to :method, opts
    content_tag :a, raw(text), opts
  end

  def data_option_for_link_to key, opts
    return unless (val = opts.delete key)
    opts["data-#{key}"] = val
  end
end

format :css do
  def link_to _text, href, _opts={}
    card_url interpret_pathish(href)
  end
end
