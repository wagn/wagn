# -*- encoding : utf-8 -*-
# helper for urls, links, redirects, and other location related things.
#  note: i'm sure this isn't the optimal name..
module Wagn::Location

  # we keep a history stack so that in the case of card removal
  # we can crawl back up to the last un-removed location

  #
  def location_history
    #warn "sess #{session.class}, #{session.object_id}"
    session[:history] ||= [wagn_path('')]
    if session[:history]
      session[:history].shift if session[:history].size > 5
      session[:history]
    end
  end

  def save_location
    return if ajax? || !html? || !@card.known?

    discard_locations_for @card
    @previous_location = wagn_path @card
    location_history.push @previous_location
  end

  def previous_location
    @previous_location ||= location_history.last if location_history
  end

  def discard_locations_for(card)
    # quoting necessary because cards have things like "+*" in the names..
    session[:history] = location_history.reject do |loc|
      if url_key = url_key_for_location(loc)
        url_key.to_name.key == card.key
      end
    end.compact
    @previous_location = nil
  end

  def url_key_for_location(location)
    location.match( /\/([^\/]*$)/ ) ? $1 : nil
  end

   # -----------( urls and redirects from application.rb) ----------------


  # TESTME
  def page_path title, opts={}
    
    format = opts[:format] ? ".#{opts.delete(:format)}"  : ''
    query  = opts.present? ? "?#{opts.to_param}"         : ''
    wagn_path "#{title.to_name.url_key}#{format}#{query}"
  end

  def wagn_path rel #should be in smartname?
    rel_path = Card===rel ? rel.cardname.url_key : rel.to_s
    if rel_path =~ /^\//
      rel_path
    else
      "#{ Wagn.config.relative_url_root }/#{ rel_path }"
    end
  end

  def wagn_url rel #should be in smartname?
    if rel =~ /^https?\:/
      rel
    else
      "#{ Card::Env[:protocol] }#{ Card::Env[:host] }#{ wagn_path rel }"
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
