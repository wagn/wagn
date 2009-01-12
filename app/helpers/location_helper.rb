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
     
  def previous_location
    location_history.last
  end
               
  def discard_locations_for(card)  
    # quoting necessary because cards have things like "+*" in the names..
    pattern = /#{Regexp.quote(card.id.to_s)}|#{Regexp.quote(card.key)}|#{Regexp.quote(card.name)}/       
    while location_history.last =~ pattern
      location_history.pop
    end
  end
   
   # -----------( urls and redirects from application.rb) ----------------

       
  def url_for_page( title, opts={} )   
    # shaved order of magnitude off footer rendering
    # vs. url_for( :action=> .. )
    "/wagn/#{title.to_url_key}"
  end  
  
  def url_for_card( options={} )
    url_for options_for_card( options )
  end
            
  # Links ----------------------------------------------------------------------
 
  def link_to_page( text, title=nil, options={} )
    title ||= text                              
    if (options.delete(:include_domain)) 
      link_to text, System.base_url.gsub(/\/$/,'') + url_for_page(title, :only_path=>true )
    else
      link_to text, url_for_page( title ), options
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
  
  def down_arrow
    %{
       <!--[if lt IE 7]>
         <img class="down-arrow" alt="&darr;" src="/images/arrow_down.gif" />     
       <![endif]-->
       <!--[if !lt IE 7]><![IGNORE[--><![IGNORE[]]>          
         <img class="down-arrow" alt="&darr;" src="/images/arrow_down.png" />
       <!--<![endif]-->
     }
  end

  def right_arrow
    %{
       <!--[if lt IE 7]>
         <img class="right-arrow" alt="&rarr;" src="/images/arrow_right.gif" />     
       <![endif]-->
       <!--[if !lt IE 7]><![IGNORE[--><![IGNORE[]]>          
         <img class="right-arrow" alt="&rarr;" src="/images/arrow_right.png" />
       <!--<![endif]-->
     }
  end
  
  def page_icon(card)
    title = "Go to: #{card.name}"
    args = [ card.name, {:class=>'page-icon-link'} ]
    
    %{
       <!--[if lt IE 7]>
         #{link_to_page image_tag('page.gif', :title=>title), *args }
       <![endif]-->
       <!--[if !lt IE 7]><![IGNORE[--><![IGNORE[]]>
         #{link_to_page image_tag('page.png', :title=>title), *args }
       <!--<![endif]-->
     }
    
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