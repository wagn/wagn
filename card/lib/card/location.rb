class Card
  module Location
    # page_path    takes a Card::Name, adds the format and query string to
    #              url_key (site-absolute)
    # card_path    makes a relative path site-absolute (if not already)
    # card_url     makes it a full url (if not already)

    # TESTME
    def page_path title, opts={}
      Rails.logger.warn "Pass only Card::Name to page_path #{title.class}, #{title}" unless Card::Name === title
      format = opts[:format] ? ".#{opts.delete(:format)}" : ""
      action = opts[:action] ? "#{opts.delete(:action)}/" : ""
      query  = opts.present? ? "?#{opts.to_param}" : ""
      card_path "#{action}#{title.to_name.url_key}#{format}#{query}"
    end

    def card_path rel_path
      Rails.logger.warn "Pass only strings to card_path: #{rel_path.class}, #{rel_path}" unless String === rel_path
      if rel_path =~ /^\//
        rel_path
      else
        "#{Card.config.relative_url_root}/#{rel_path}"
      end
    end

    def card_url rel
      if rel =~ /^https?\:/
        rel
      else
        "#{Card::Env[:protocol]}#{Card::Env[:host]}#{card_path rel}"
      end
    end

    extend Location
  end
end
