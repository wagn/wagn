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
      when /^\//
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
    if opts[:action] == :new && opts[:type] &&
       !(opts[:name] || opts[:card] || opts[:id])
      opts.delete(:action)
      base = "new/#{opts.delete(:type)}"
    else
      name = opts.delete(:name) || card.name
      base = opts[:action] ? "card/#{opts.delete :action}/" : ""

      opts[:no_id] = true if [:new, :create].member? opts[:action]
      # generalize. dislike hardcoding views/actions here

      linkname = name.to_name.url_key
      unless name.empty? || opts.delete(:no_id)
        base += (opts[:id] ? "~#{opts.delete :id}" : linkname)
      end

      process_path_card_opts opts, name, linkname
    end

    query = opts.empty? ? "" : "?#{opts.to_param}"
    internal_url(base + query)
  end

  def internal_url relative_path
    card_path relative_path
  end

  def interpret_href href
    href.is_a?(Hash) ? path(href) : href
  end

  def process_path_card_opts opts, name, linkname
    opts[:card] ||= {}
    if opts.delete(:known) == false && name.present? && name.to_s != linkname
      opts[:card][:name] = name
    end

    if (type = opts.delete(:type)) && Card.known?(type)
      opts[:card][:type] = type
    end
    opts.delete(:card) if opts[:card].empty?
  end
end

format :html do
  def link_to text, href, opts={}
    href = interpret_href href

    [:remote, :method].each do |key|
      if (val = opts.delete(key))
        opts["data-#{key}"] = val
      end
    end

    content_tag :a, raw(text), opts.merge(href: href)
  end
end

format :css do
  def link_to _text, href, _opts={}
    interpret_href href
  end
end
