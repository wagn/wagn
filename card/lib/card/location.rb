# -*- encoding : utf-8 -*-
# helper for urls, links, redirects, and other location related things.
#  note: i'm sure this isn't the optimal name..

module Card::Location

 # -----------( urls and redirects from application.rb) ----------------

  # TESTME
  def page_path title, opts={}
    
    format = opts[:format] ? ".#{opts.delete(:format)}"  : ''
    query  = opts.present? ? "?#{opts.to_param}"         : ''
    card_path "#{title.to_name.url_key}#{format}#{query}"
  end

  def card_path rel #should be in smartname?
    rel_path = Card===rel ? rel.cardname.url_key : rel.to_s
    if rel_path =~ /^\//
      rel_path
    else
      "#{ Card.config.relative_url_root }/#{ rel_path }"
    end
  end

  def card_url rel #should be in smartname?
    if rel =~ /^https?\:/
      rel
    else
      "#{ Card::Env[:protocol] }#{ Card::Env[:host] }#{ card_path rel }"
    end
  end


  # Links ----------------------------------------------------------------------

  def link_to_page( text, title=nil, options={})
    title ||= text
    url_options = {}
    [:type, :view].each { |k| url_options[k] = options.delete(k) if options[k] }
    url = page_path( title, url_options )
    link_to text, url, options
  end

end
