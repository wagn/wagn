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
    return if ajax? || !html? || !@card.known? || (@card.codename == 'signin')
    discard_locations_for @card
    @previous_location = wagn_path @card.cardname.url_key
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
  
  def save_interrupted_action uri
    uri = path(uri) if Hash === uri
    session[:interrupted_action] = uri
  end
  
  def interrupted_action
    session.delete :interrupted_action
  end

  #
  # page_path    takes a Card::Name, adds the format and query string to url_key (site-absolute)
  # wagn_path    makes a relative path site-absolute (if not already)
  # wagn_url     makes it a full url (if not already)

  # TESTME
  def page_path title, opts={}
    Rails.logger.warn "Pass only Card::Name to page_path #{title.class}, #{title}" unless Card::Name===title
    format = opts[:format] ? ".#{opts.delete(:format)}"  : ''
    query  = opts.present? ? "?#{opts.to_param}"         : ''
    wagn_path "#{title.url_key}#{format}#{query}"
  end

  def wagn_path rel_path
    Rails.logger.warn "Pass only strings to wagn_path: #{rel_path.class}, #{rel_path}" unless String===rel_path
    if rel_path =~ /^\//
      rel_path
    else
      "#{ Wagn.config.relative_url_root }/#{ rel_path }"
    end
  end

  def wagn_url rel
    if rel =~ /^https?\:/
      rel
    else
      "#{ Card::Env[:protocol] }#{ Card::Env[:host] }#{ wagn_path rel }"
    end
  end

end
