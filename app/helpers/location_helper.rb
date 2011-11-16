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
  # a card may be on the location stack multiple times, especially if
  # you had to confirm before removing.
  #
  def location_history
    session[:history] ||= ['/']
    session[:history].shift if session[:history].size > 5
    session[:history]
  end

  def save_location
    location_history.push(request.fullpath)
    @previous_location = nil
  end

  def previous_location
    @previous_location ||= location_history.last
  end

  def discard_locations_for(card)
    # quoting necessary because cards have things like "+*" in the names..
    pattern = /#{Regexp.quote(card.id.to_s)}|#{Regexp.quote(card.key)}|#{Regexp.quote(card.name)}/
    while location_history.last =~ pattern
      location_history.pop
    end
    @previous_location = nil
  end

   # -----------( urls and redirects from application.rb) ----------------


  # FIXME: missing test
  def url_for_page( title, opts={} )
    format = (opts[:format] ? ".#{opts.delete(:format)}"  : "")
    vars = ''
    if !opts.empty?
      pairs = []
      opts.each_pair{|k,v| pairs<< "#{k}=#{v}"}
      vars = '?' + pairs.join('&')
    end
    # shaved order of magnitude off footer rendering
    # vs. url_for( :action=> .. )
#Rails.logger.debug "url_for_page( #{title}, #{format}, #{vars}"
    "/wagn/#{title.to_cardname.to_url_key}#{format}#{vars}"
  end

  def url_for_card( options={} )
    url_for options_for_card( options )
  end

  def card_path( card )
    "/wagn/#{card.cardname.to_url_key}"
  end

  def card_url( card )
    "http://" + System.host + card_path(card)
  end

  # Links ----------------------------------------------------------------------

  def link_to_page( text, title=nil, options={})
    title ||= text
    url_options = (options[:type]) ? {:type=>options[:type]} : {}
    url = url_for_page(title, url_options)
    url = System.base_url + url if (options.delete(:include_domain))

    #Rails.logger.debug("link_to_page #{options.inspect}")
    link_to text, url, options
  end

  def card_title_span( title )
    %{<span class="namepart-#{title.to_cardname.css_name}">#{title}</span>}
  end

  def page_icon(cardname)
    link_to_page '&nbsp;'.html_safe, cardname, {:class=>'page-icon', :title=>"Go to: #{cardname.to_s}"}
  end
end
