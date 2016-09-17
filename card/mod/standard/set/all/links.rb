format do
  # link is called by web_link, card_link, and view_link
  # (and is overridden in other formats)
  def link_to text, href, _opts={}
    href = interpret_href href

    if text && href != text
      "#{text}[#{href}]"
    else
      href
    end
  end

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
      when /^mailto\:/
        "email-link"
      when /^([a-zA-Z][\-+\.a-zA-Z\d]*):/
        Regexp.last_match(1) + "-link"
      when %r{^/}
        href = internal_url href[1..-1]
        "internal-link"
      else
        return card_link href, opts
      end
    add_class opts, new_class
    link_to text, href, opts
  end

  # link to a specific card
  def card_link name_or_card, opts={}
    name =
      case name_or_card
      when Symbol then Card.fetch(name_or_card, skip_modules: true).cardname
      when Card   then name_or_card.cardname
      else             name_or_card
      end
    text = (opts.delete(:text) || name).to_name.to_show @context_names

    path_opts = opts.delete(:path_opts) || {}
    path_opts[:name] = name
    path_opts[:known] =
      opts[:known].nil? ? Card.known?(name) : opts.delete(:known)
    add_class opts, (path_opts[:known] ? "known-card" : "wanted-card")
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

  def related_link name_or_card, opts={}
    name =
      case name_or_card
      when Symbol then Card.fetch(name_or_card, skip_modules: true).cardname
      when Card   then name_or_card.cardname
      else             name_or_card
      end
    opts[:path_opts] ||= { view: :related }
    opts[:path_opts][:related] = { name: "+#{name}" }
    opts[:path_opts][:related].merge! opts[:related_opts] if opts[:related_opts]
    view_link(opts[:text] || name, :related, opts)
  end

  def path opts={}
    base = new_cardtype_path(opts) || standard_path(opts)
    query = path_query(opts)
    internal_url base + query
  end

  def new_cardtype_path opts
    return unless opts[:action] == :new
    opts.delete :action
    return unless opts[:type] && !opts[:name] && !opts[:card] && !opts[:id]
    "new/#{opts.delete :type}"
  end

  def standard_path opts
    standardize_action! opts
    path_action = case opts[:action]
                  when :create then "card/#{opts[:action]}/"
                  # sometimes create action has no mark,
                  # but /create refers to a card named "create"
                  when nil     then ""
                  else              "#{opts[:action]}/"
                  end
    path_action + path_mark(opts)
  end

  def standardize_action! opts
    return if [:create, :update, :delete].member? opts[:action]
    opts.delete :action
  end

  def path_mark opts
    if (id = opts.delete :id) && id.present? && !opts.delete(:no_id)
      "~#{id}"
    else
      (opts[:name] || card.name).to_name.url_key
    end
  end

  def path_query opts
    card_opts = opts.delete(:card) || {}
    if opts.delete :action
      assign_path_card_opt card_opts, :name, opts
      assign_path_card_opt card_opts, :type, opts
    end
    opts[:card] = card_opts unless card_opts.empty?
    opts.empty? ? "" : "?#{opts.to_param}"
  end

  def assign_path_card_opt card_opts, field, opts
    return if card_opts[field]
    return unless (new_value = send "new_#{field}_in_path", opts)
    card_opts[field] = new_value
  end

  def new_name_in_path action, opts
    optname = opts.delete :name
    name = optname || card.name
    case action
    when :create
      linkname = name.to_name.url_key
      name if name != linkname
    when :update
      optname if optname != name
    end
  end

  def new_type_in_path_opts opts
    type = opts.delete(:type)
    return type if type && Card.known?(type)
  end

  def internal_url relative_path
    card_path relative_path
  end

  def interpret_href href
    href.is_a?(Hash) ? path(href) : href
  end
end

format :html do
  def link_to text, href, opts={}
    opts[:href] = interpret_href href

    [:remote, :method].each do |key|
      next unless (val = opts.delete key)
      opts["data-#{key}"] = val
    end

    content_tag :a, raw(text), opts
  end
end

format :css do
  def link_to _text, href, _opts={}
    card_url interpret_href(href)
  end
end
