# -*- encoding : utf-8 -*-
# helper for urls, links, redirects, and other location related things.
#  note: i'm sure this isn't the optimal name..
module LocationHelper

  # the location_history mechanism replaces
  # store_location() & redirect_back_or_default() from the
  # authenticated helper.
  #
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


  # FIXME: missing test
  def path_for_page( title, opts={} )
    format = (opts[:format] ? ".#{opts.delete(:format)}"  : "")
    vars = ''
    if !opts.empty?
      pairs = []
      opts.each_pair{|k,v| pairs<< "#{k}=#{v}"}
      vars = '?' + pairs.join('&')
    end
    wagn_path "/#{title.to_name.url_key}#{format}#{vars}"
  end

  def wagn_path rel #should be in smartname?
    rel_path = Card===rel ? rel.cardname.url_key : rel
    Rails.logger.warn "wagn_path #{rel.inspect}, #{rel_path}, [#{Wagn::Conf[:root_path]}, #{Wagn::Conf[:base_url]}]"
    Wagn::Conf[:root_path].to_s + ( rel_path =~ /^\// ? '' : '/' ) + rel_path
  end

  def wagn_url rel #should be in smartname?
    Rails.logger.warn "wagn_url #{rel}, [#{Wagn::Conf[:base_url]}]"
    rel =~ /^http\:/ ? rel : "#{Wagn::Conf[:base_url]}#{wagn_path(rel)}"
  end


  # Links ----------------------------------------------------------------------

  def link_to_page( text, title=nil, options={})
    title ||= text
    url_options = (options[:type]) ? {:type=>options[:type]} : {}
    url = path_for_page(title, url_options)
    link_to text, url, options
  end

end
