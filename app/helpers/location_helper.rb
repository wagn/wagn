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
    location_history.push(request.request_uri)
    load_location
  end
     
  def load_location
    @previous_location = location_history.last
  end
    
  def previous_location
    @previous_location
  end
               
  def discard_locations_for(card)  
    # quoting necessary because cards have things like "+*" in the names..
    pattern = /#{Regexp.quote(card.id.to_s)}|#{Regexp.quote(card.key)}|#{Regexp.quote(card.name)}/       
    while location_history.last =~ pattern
      location_history.pop
    end  
    load_location
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
    "/wagn/#{title.to_url_key}#{format}#{vars}" 
  end  
  
  def url_for_card( options={} )
    url_for options_for_card( options )
  end
       
  def card_path( card )
    "/wagn/#{card.name.to_url_key}" 
  end            
  
  def card_url( card )
    "http://" + System.host + card_path(card)
  end
  
  # Links ----------------------------------------------------------------------
 
  def link_to_page( text, title=nil, options={})
    title ||= text
    url_options = (options[:type]) ? {:type=>options[:type]} : {}                              
    if (options.delete(:include_domain)) 
      link_to text, System.base_url + url_for_page(title, url_options) #, :only_path=>true )
    else
      link_to text, url_for_page( title, url_options ), options
    end
  end  
    
  def link_to_connector_update( text, highlight_group, connector_method, value, *method_value_pairs )
    #warn "method_value_pairs: #{method_value_pairs.inspect}"
    extra_calls = method_value_pairs.size > 0 ? ".#{method_value_pairs[0]}('#{method_value_pairs[1]}')" : ''
    link_to_function( text, 
      "Wagn.highlight('#{highlight_group}', '#{value}'); " +
      "Wagn.lister().#{connector_method}('#{value}')#{extra_calls}.update()",
      :class => highlight_group,
      :id => "#{highlight_group}-#{value}"
    )
  end
  
  def name_in_context(card, context_card)
    context_card == card ? card.name : card.name.gsub(context_card.name, '')
  end
  
  def card_title_span( title )
    %{<span class="title-#{css_name(title)} card">#{title}</span>}
  end
  
  def connector_function( name, *args )
    "Wagn.lister().#{name.to_s}(#{args.join(',')});"
  end             
  
  def pieces_icon( card, prefix='' )
    image_tag "/images/#{prefix}pieces_icon.png", :title=>"cards that comprise \"#{card.name}\""
  end  
  
  def connect_icon( card, prefix='' )
    image_tag "/images/#{prefix}connect_icon.png", :title=>"plus cards that include \"#{card.name}\""
  end         
  
  def connected_icon( card, prefix='' )
    image_tag "/images/#{prefix}connected_icon.png", :title=>"cards connected to \"#{card.name}\""
  end
  

  def page_icon(cardname)
    link_to_page '&nbsp;', cardname, {:class=>'page-icon', :title=>"Go to: #{cardname}"} 
  end

  def flexlink( linktype, name, options )
    case linktype
      when 'connect'
        link_to_function( name,
           "var form = window.document.forms['connect'];\n" +
           "form.elements['name'].value='#{name}';\n" +
           "form.onsubmit();",
           options)
      when 'page'
        link_to_page name, name, options
      else
        raise "no linktype specified"
    end
  end
  
end