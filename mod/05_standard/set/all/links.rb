

format do

  # link is called by web_link, card_link, and view_link
  # (and is overridden in other formats)
  def link_to text, href, opts={}
    if text and href != text
      "#{text}[#{href}]"
    else
      href
    end
  end

  # link to a specific url or path
  def web_link href, opts={}
    text = opts.delete(:text) || href
    new_class = case href
      when /^https?:/                      ; 'external-link'
      when /^mailto:/                      ; 'email-link'
      when /^([a-zA-Z][\-+\.a-zA-Z\d]*):/  ; $1 + '-link'
      when /^\//
        href = internal_url href[1..-1]    ; 'internal-link'
      else
        return card_link href, options
      end
    add_class opts, new_class        
    link_to text, href, opts
  end

  # link to a specific card
  def card_link name, opts={}
    text = (opts.delete(:text) || name).to_name.to_show @context_names
    
    path_opts = opts.delete( :path_opts ) || {}
    path_opts[:name ] = name
    path_opts[:known] = opts[:known].nil? ? Card.known?(name) : opts.delete(:known) 
    add_class opts, ( path_opts[:known] ? 'known-card' : 'wanted-card' )
    link_to text, path_opts, opts
  end


  # link to a specific view (defaults to current card)
  # this is generally used for ajax calls
  def view_link text, view, opts={}
    path_opts = opts.delete( :path_opts ) || {}
    path_opts[:view] = view unless view == :home
    opts[:remote] = true
    opts[:rel] = 'nofollow'
    
    link_to text, path_opts, opts
  end

  def path opts={}
    name = opts.delete(:name) || card.name
    base = opts[:action] ? "card/#{ opts.delete :action }/" : ''
    
    opts[:no_id] = true if [:new, :create].member? opts[:action]
    #generalize. dislike hardcoding views/actions here
    
    linkname = name.to_name.url_key
    unless name.empty? || opts.delete(:no_id)
      base += ( opts[:id] ? "~#{ opts.delete :id }" : linkname )
    end
    
    opts[:card] = {}
    opts[:card][:name] = name if opts.delete(:known)==false && name.present? && name.to_s != linkname
    
    if type = opts.delete(:type) and Card.known?( type )
      opts[:card][:type] = type
    end
    opts.delete(:card) if opts[:card].empty?
    
    query = opts.empty? ? '' : "?#{opts.to_param}"
    internal_url( base + query )
  end

  def internal_url relative_path
    wagn_path relative_path
  end
  
end

format :html do
  
  
  def link_to text, href, opts={}
    if Hash===href
      href = path href
    end

    [:remote, :method].each do |key|
      if val = opts.delete(key)
        opts["data-#{key}"] = val
      end
    end
    
    content_tag :a, raw(text), opts.merge(:href=>href)
  end
  
end