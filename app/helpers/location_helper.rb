# helper for urls, links, redirects, and other location related things.
#  note: i'm sure this isn't the optimal name..
module LocationHelper 
  
  # -----------( urls and redirects from application.rb) ----------------
  def remember_card( card )
    #warn "SESSION RETURN STACK:  #{session[:return_stack].inspect}"
    return unless card
    session[:return_stack] ||= [] 
    session[:return_stack].push( card.id ) unless session[:return_stack].last == card.id
    session[:return_stack].shift if session[:return_stack].length > 4 
  end

  
  def return_to_remembered_page( options={} )
    redirect_to_page url_for_previous_page, options
  end
  
  def previous_page    
    # FIXME please
    name = ''
    session[:return_stack] ||= []
    session[:return_stack].reverse.each do |id|
      #warn "EXAMINING CARD ID: #{id}"
      if ((Fixnum === id && card = Card.find_by_id_and_trash( id, false )) || 
            card=Card.find_by_key_and_trash( id, false ))
        name = card.name
        break
      end
    end                 
    name
  end
  
  def url_for_previous_page
    name = previous_page
    name.empty? ? '/' : url_for_page( name )
  end        
  
  
   ## FIXME should be using rjs for this...
  def redirect_to_page( url, options={} )
    #url = name.empty? ? '/' : url_for_page( name )
    if options[:javascript] 
      render :inline=>%{<%= javascript_tag "document.location.href='#{url}'" %>Returning to previous card...}
    else
      redirect_to url 
    end    
  end   
       
  def url_for_page( title, opts={} )   
    # shaved order of magnitude off footer rendering
    # vs. url_for( :action=> .. )
    "/wagn/#{Cardname.escape(title)}"
  end  
  
  def url_for_card( options={} )
    url_for options_for_card( options )
  end
            
  def previous_page_function
    "document.location.href='#{url_for_page(previous_page)}'"
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
  
  def page_icon(card)
    #link_to_remote( image_tag('page.png', :title=>"Card Page for: #{card.name}"),
    #  :url=>slot.url_for("card/view"),
    #  :update => "javascript:getSlotFromContext('main_1')"
    #)
    link_to_page image_tag('page.png', :title=>"Card Page for: #{card.name}"), card.name
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