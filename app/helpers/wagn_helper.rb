require_dependency 'slot'

module WagnHelper
  require_dependency 'wiki_content'
  
  def get_slot(card=nil, context=nil, action=nil)     
    card ||= @card; context||=@context; action||=@action
    #FIMXE-- this isn't quite right for multiple cards in a toplevel context, like sidebar
    slot = case 
      when controller.slot && card==@card; controller.slot
      when controller.slot;  controller.slot.subslot(card)  
      else controller.slot = Slot.new(@card,@context,@action,self) 
    end
  end
      
  # FIMXE: this one's a hack...
  def render_card(card, mode)
    if String===card && name = card  
      raise("Card #{name} not present") unless card=(Card[name] || Card.find_phantom(name))
    end
    controller.slot.subslot(card).render(mode.to_sym)
  end
  
  Droplet = Struct.new(:name, :link_options)     
       
  module MyCrappyJavascriptHack
    def select_slot(pattern)
      ActionView::Helpers::JavaScriptCollectionProxy.new(self, "$A([#{pattern}])")
    end
  end 

  # This is a slight modification of the stock rails method to accomodate 
  # bare javascript
  def remote_function(options)
    javascript_options = options_for_ajax(options)

    update = ''
    if options[:update] =~ /^javascript\:/
      update << options[:update].gsub(/^javascript\:/,'')
    elsif options[:update] && options[:update].is_a?(Hash)
      update  = [] 
      if succ = options[:update][:success] 
        update << "success:" + (succ.gsub!(/^javascript:/,'') ? succ : "'#{succ}'")
      end
      if fail = options[:update][:failure]   
        update << "failure:" + (fail.gsub!(/^javascript:/,'') ? fail : "'#{succ}'")
      end
      update  = '{' + update.join(',') + '}'
    elsif options[:update]
      update << "'#{options[:update]}'"
    end

    function = update.empty? ? 
      "new Ajax.Request(" :
      "new Ajax.Updater(#{update}, "

    if options[:url] =~ /^javascript\:/
      function << options[:url].gsub(/^javascript\:/,'')
    else
      url_options = options[:url]
      url_options = url_options.merge(:escape => false) if url_options.is_a?(Hash)
      function << "'#{url_for(url_options)}'" 
    end
    
    function << ", #{javascript_options})"

    function = "#{options[:before]}; #{function}" if options[:before]
    function = "#{function}; #{options[:after]}"  if options[:after]
    function = "if (#{options[:condition]}) { #{function}; }" if options[:condition]
    function = "if (confirm('#{escape_javascript(options[:confirm])}')) { #{function}; }" if options[:confirm]

    return function
  end

  def previous_page_function
    "document.location.href='#{url_for_page(previous_page)}'"
  end
    
  def truncatewords_with_closing_tags(input, words = 25, truncate_string = "...")
    if input.nil? then return end
    wordlist = input.to_s.split
    l = words.to_i - 1
    l = 0 if l < 0
    wordstring = wordlist.length > l ? wordlist[0..l].join(" ") : input     
    # nuke partial tags at end of snippet
    wordstring.gsub!(/(<[^\>]+)$/,'')
    
    tags = []
    
    # match tags with or without self closing (ie. <foo />)
    wordstring.scan(/\<([^\>\s\/]+)[^\>]*?\>/).each { |t| tags.unshift(t[0]) }

    # match tags with self closing and mark them as closed
    wordstring.scan(/\<([^\>\s\/]+)[^\>]*?\/\>/).each { |t| if !(x=tags.index(t[0])).nil? then tags.slice!(x) end }
    
    # match close tags
    wordstring.scan(/\<\/([^\>\s\/]+)[^\>]*?\>/).each { |t|  if !(x=tags.index(t[0])).nil? then tags.slice!(x) end  }
    
    tags.each {|t| wordstring += "</#{t}>" }
    
    wordstring +='<span style="color:#666"> ...</span>' if wordlist.length > l    
#    wordstring += '...' if wordlist.length > l    
    wordstring.gsub! /<br[\s\/]*>/, ' ' ## Also a hack -- get rid of <br>'s -- they make line view ugly.
    wordstring
  end
  

  def partial_for_action( name, card=nil )
    # FIXME: this should look up the inheritance hierarchy, once we have one
    cardtype = (card ? card.type : 'Basic').underscore
    file_exists?("/cardtypes/#{cardtype}/_#{name}") ? 
      "/cardtypes/#{cardtype}/#{name}" :
      "/cardtypes/basic/#{name}"
  end

  def formal_joint
    " <span class=\"wiki-joint\">#{JOINT}</span> "
  end
  
  def formal_title(card)
    card.name.split(JOINT).join(formal_joint)
  end
  
  def less_fancy_title(card)
    name = card.name
    return name if name.simple?
    card_title_span(name.parent_name) + %{<span class="joint">#{JOINT}</span>} + card_title_span(name.tag_name)
  end
  
  def title_tag_names(card)
    card.name.split(JOINT)
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
  
  def link_to_options( element_id, args={} )
    args = {
      :show_text => "&raquo;&nbsp;show&nbsp;options", 
      :hide_text => "&laquo;&nbsp;hide&nbsp;options",
      :mode      => 'show'
    }.merge args
    
    off = 'display:none'
    show_style, hide_style = (args[:mode] != 'show' ?  [off, ''] : ['', off])     
    
    show_link = link_to_function( args[:show_text], 
        %{ Element.show("#{element_id}-hide");
           Element.hide("#{element_id}-show");
           Effect.BlindDown("#{element_id}", {duration:0.4})
         },
         :id=>"#{element_id}-show",
         :style => show_style
     )
     hide_link = link_to_function( args[:hide_text],
        %{ Element.hide("#{element_id}-hide"); 
           Element.show("#{element_id}-show"); 
           Effect.BlindUp("#{element_id}", {duration:0.4})
        },
        :id=>"#{element_id}-hide", 
        :style=>hide_style
      )
      show_link + hide_link 
  end
  
  def name_in_context(card, context_card)
    context_card == card ? card.name : card.name.gsub(context_card.name, '')
  end
  
  
  def query_title(query, card_name)
    title = {
      :plus_cards => "Junctions: we join %s to other cards",
      :plussed_cards => "Joinees: we're joined to %s",
      :backlinks => 'Links In: we link to %s',
      :linksout => "Links Out: %s links to us",
      :cardtype_cards => card_name.pluralize + ': our cardtype is %s',
      :pieces => 'Pieces: we join to form %s',
      :revised_by => 'Edits: %s edited these cards'
    }
    title[query.to_sym] % ('"' + card_name + '"')
  end
  
  def query_options(card)
    options_for_select card.queries.map{ |q| [query_title(q,card.name), q ] }
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
    #  :update => "javascript:getSlotFromContext('main:1')"
    #)
    link_to_page image_tag('page.png', :title=>"Card Page for: #{card.name}"), card.name
  end
  # Other snippets -------------------------------------------------------------

  def site_name
    System.site_name
  end
    
  def css_name( name )
    name.gsub(/#{'\\'+JOINT}/,'-').gsub(/[^\w-]+/,'_')
  end
  
  #def related
  #  render :partial=> 'card/related'
  #end
  
  def sidebar
    render :partial=>partial_for_action('sidebar', @card)
  end

  def format_date(date, include_time = true)
    # Must use DateTime because Time doesn't support %e on at least some platforms
    if include_time
      DateTime.new(date.year, date.mon, date.day, date.hour, date.min, date.sec).strftime("%B %e, %Y %H:%M:%S")
    else
      DateTime.new(date.year, date.mon, date.day).strftime("%B %e, %Y")
    end
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
  
  def createable_cardtypes
    User.current_user.createable_cardtypes
  end
    

  ## ----- for Linkers ------------------  
  def cardtype_options
    User.current_user.createable_cardtypes.map do |cardtype|
      next(nil) if cardtype[:codename] == 'User' #or cardtype[:codename] == 'InvitationRequest'
      [cardtype[:codename], cardtype[:name]]
    end.compact
  end

  def cardtype_options_for_select(selected=Card.default_cardtype_key)
    #warn "SELECTED = #{selected}"
    options_from_collection_for_select(cardtype_options, :first, :last, selected)
  end


  def button_to_remote(name,options={},html_options={})
    button_to_function(name, remote_function(options), html_options)
  end          
  
  
  def stylesheet_inline(name)
    out = %{<style type="text/css" media="screen">\n}
    out << File.read("#{RAILS_ROOT}/public/stylesheets/#{name}.css")
    out << "</style>\n"
  end

  
end



