module WagnHelper
  require_dependency 'wiki_content'

  Droplet = Struct.new(:name, :link_options)
  
  class Slot
    attr_reader :card, :context, :action, :id
    attr_accessor :editor_id
    def initialize(card, context, action, template, options, proc)
      @card, @context, @action, @template, @options, @proc = card, context.to_s, action.to_s, template, options, proc
      @id = @template.slot_id(@card, @context)
    end

    def method_missing(method_id, *args)
      @template.send("slot_#{method_id}", self, *args)
    end
  end
  
  def slot_id(card, context) 
    context=='main' ? 'main-card' : "#{context}-#{card.id}"
  end

  def slot_for( card, context, action, options={}, &proc )
    options[:render_slot] = !request.xhr? if options[:render_slot].nil?            
    slot = Slot.new(card, context, action, self, options, proc)
    if options[:render_slot]
      css_class = ''      
      if slot.action=='line'  
        css_class << 'line' 
      else
        css_class << 'paragraph'                     
      end
      css_class << ' full' if context=='main'
      css_class << ' sidebar' if context=='sidebar'
      concat(%{<div id="#{slot.id}" class="card-slot #{css_class}">}, proc.binding) 
      yield slot
      concat(%{</div>}, proc.binding)
    else
      yield slot
    end
  end 

  def slot_name_area(slot)
    slot.id + "-name"
  end

  def slot_cardtype_area(slot)
    slot.id + "-cardtype"
  end

  def slot_url_for_action(slot,action)
    "/card/#{action}/#{slot.card.id}" + slot.context_cgi
  end

  def slot_url_for_name_action(slot,action)
    "/cardname/#{action}/#{slot.card.id}" + slot.context_cgi
  end

  def slot_url_for_cardtype_action(slot,action)
    "/cardtype/#{action}/#{slot.card.id}" + slot.context_cgi
  end


  def slot_header(slot)
    render :partial=>'card/header', :locals=>{ :card=>slot.card, :slot=>slot }
  end

  def slot_footer(slot)
    render :partial=>"card/footer", :locals=>{ :card=>slot.card, :slot=>slot }
  end


  def slot_link_to_action(slot, text, to_action, remote_opts={}, html_opts={})
    link_to_remote text, remote_opts.merge(
      :url=>slot.url_for_action(to_action),
      :update => slot.id
    ), html_opts
  end

  def slot_button_to_action(slot, text, to_action, remote_opts={}, html_opts={})
    button_to_remote text, remote_opts.merge(
      :url=>slot.url_for_action(to_action),
      :update => slot.id
    ), html_opts
  end
  
  def slot_context_cgi(slot)
    slot.context=='main' ? '' : "?context=#{slot.context}"
  end
  
  def slot_link_to_menu_action(slot, to_action)
    slot.link_to_action to_action.capitalize, to_action, {},
      :class=> (slot.action==to_action ? 'current' : '')
  end
       
  def slot_render_partial(slot, partial, args={})
    # FIXME: this should look up the inheritance hierarchy, once we have one
    render :partial=> partial_for_action(partial, slot.card), 
      :locals => args.merge({ :card=>slot.card, :slot=>slot })
  end

  def slot_editor_hooks(slot,hooks)
    # it seems as though code executed inline on ajax requests works fine
    # to initialize the editor, but when loading a full page it fails-- so
    # we run it in an onLoad queue.  the rest of this code we always run
    # inline-- at least until that causes problems.
    code = ""
    if hooks[:setup]
      code << "Wagn.onLoadQueue.push(function(){\n" unless request.xhr?
      code << hooks[:setup]
      code << "});\n" unless request.xhr?
    end
    if hooks[:save]
      code << "if (typeof(Wagn.onSaveQueue['#{slot.id}'])=='undefined') {\n"
      code << "  Wagn.onSaveQueue['#{slot.id}']=$A([]);\n"
      code << "}\n"
      code << "Wagn.onSaveQueue['#{slot.id}'].push(function(){\n"
      code << hooks[:save]
      code << "});\n"
    end
    if hooks[:cancel]
      code << "if (typeof(Wagn.onCancelQueue['#{slot.id}'])=='undefined') {\n"
      code << "  Wagn.onCancelQueue['#{slot.id}']=$A([]);\n"
      code << "}\n"
      code << "Wagn.onCancelQueue['#{slot.id}'].push(function(){\n"
      code << hooks[:cancel]
      code << "});\n"
    end
    javascript_tag code
  end
  
  def truncatewords_with_closing_tags(input, words = 15, truncate_string = "...")
    if input.nil? then return end
    wordlist = input.to_s.split
    l = words.to_i - 1
    l = 0 if l < 0
    wordstring = wordlist.length > l ? wordlist[0..l].join(" ") : input
    h1 = {}
    h2 = {}
    wordstring.scan(/\<([^\>\s\/]+)[^\>\/]*?\>/).each { |t| h1[t[0]] ? h1[t[0]] += 1 : h1[t[0]] = 1 }
    wordstring.scan(/\<\/([^\>\s\/]+)[^\>]*?\>/).each { |t| h2[t[0]] ? h2[t[0]] += 1 : h2[t[0]] = 1 }
    h1.each {|k,v| wordstring += "</#{k}>" * (h1[k] - h2[k].to_i) if h2[k].to_i < v }
    wordstring = wordstring + "..."
  end

  # You'd think we'd want to use this one but it sure doesn't seem to work as
  # well as the truncatewords...
  def truncate_with_closing_tags(input, chars, truncate_string = "...")
    if input.nil? then return end
      code = truncate(input, chars).to_s #.chop.chop.chop
      h1 = {}
      h2 = {}
      code.scan(/\<([^\>\s\/]+)[^\>\/]*?\>/).each { |t| h1[t[0]] ? h1[t[0]] += 1 : h1[t[0]] = 1 }
      code.scan(/\<\/([^\>\s\/]+)[^\>]*?\>/).each { |t| h2[t[0]] ? h2[t[0]] += 1 : h2[t[0]] = 1 }
      h1.each {|k,v| code += "</#{k}>" * (h1[k] - h2[k].to_i) if h2[k].to_i < v }
      code = code + truncate_string
      return code
  end  
   
  def conditional_cache(card, name, &block)
    card.cacheable? ? controller.cache_erb_fragment(block, name) : block.call
  end
  
  def rendered_content( card )   
    c, name = controller, "card/content/#{card.id}"
    if c.perform_caching and card.cacheable? and content = c.read_fragment(name)
      return content
    end
    content = render :partial=>partial_for_action("content", card), :locals=>{:card=>card}
    if card.cacheable? and c.perform_caching
      c.write_fragment(name, content)
    end
    content
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
  
  def title_tag_names(card)
    card.name.split(JOINT)
  end
  
  # Urls -----------------------------------------------------------------------
  
  def url_for_page( title, opts={} )   
    # shaved order of magnitude off footer rendering
    # vs. url_for( :action=> .. )
    "/wiki/#{Cardname.escape(title)}"
    #url_for(opts.merge(
    #  :action=>'show', 
    #  :controller=>'card', 
    #  :id=>Cardname.escape(title), 
    #  :format => nil
    #))
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
  
  def fancy_title(card) fancy_title_from_tag_names(card.name.split( JOINT ))  end
  
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
  
  def fancy_title_from_tag_names(tag_names)
    tag_names.inject([nil,nil]) do |title_array, tag_name|
      title, title_link = title_array
      tag_link = link_to tag_name, url_for_page( tag_name ), :class=>"link-#{css_name(tag_name)}"
      if title 
        title = [title, tag_name].join(%{<span class="joint">#{JOINT}</span>})
        joint_link = link_to formal_joint, url_for_page(title), 
          :onmouseover=>"Wagn.title_mouseover('title-#{css_name(title)} card')",
          :onmouseout=>"Wagn.title_mouseout('title-#{css_name(title)} card-highlight')"
        title_link = "<span class='title-#{css_name(title)} card' >\n%s %s %s\n</span>" % [title_link, joint_link, tag_link]
        [title, title_link]
      else
        [tag_name, %{<span class="title-#{css_name(tag_name)} card">#{tag_link}</span>\n}]
      end
    end[1]
  end

  def less_fancy_title(card)
    name = card.name
    return name if name.simple?
    card_title_span(name.parent_name) + %{<span class="joint">#{JOINT}</span>} + card_title_span(name.tag_name)
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
  
  # Other snippets -------------------------------------------------------------

  def site_name
    System.site_name
  end
    
  def css_name( name )
    name.gsub(/#{'\\'+JOINT}/,'-').gsub(/[^\w-]+/,'_')
  end
  
  def related
    render :partial=> 'card/related'
  end
  
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
           "form.elements['card[name]'].value='#{name}';\n" +
           "form.onsubmit();",
           options)
      when 'page'
        link_to_page name, name, options
      else
        raise "no linktype specified"
    end
  end
    

  ## ----- for Linkers ------------------  
  def cardtype_options
    Cardtype.find(:all, :order=>'class_name').map do |cardtype|
      case cardtype.class_name
        when 'Connection'; next
        when 'User';       next #unless System.ok? :invite_users
#        when 'Role';       next unless System.ok? :manage_permissions
#        when 'Cardtype';   next unless System.ok? :edit_cardtypes
        else  #warn "Adding #{cardtype.class_name}"
      end                           
      [cardtype.class_name, cardtype.card.name]    
    end.compact
  end

  def cardtype_options_for_select(selected=Card.default_cardtype_key)
    #warn "SELECTED = #{selected}"
    options_from_collection_for_select(cardtype_options, :first, :last, selected)
  end

  def paging( cards )
    links = ""
    page = (params[:page] || 1).to_i 
    pagesize = (params[:pagesize] || System.pagesize).to_i
        
    if page > 1
      links << link_to_function( image_tag('prev-page.png'), "Wagn.lister().page(#{page-1}).update()")
    else
      links << image_tag('no-prev-page.png')
    end     
    offset = pagesize * (page-1)                
    links << " #{cards.length > 0 ? offset+1 : 0}-#{offset+cards.length} "     

    if cards.length == pagesize
      links << link_to_function( image_tag('next-page.png'), "Wagn.lister().page(#{page+1}).update()")   
    else
      links << image_tag('no-next-page.png')
    end
    %{<span id="paging-links" class="paging-links">#{links}</span>}
  end

  def button_to_remote(name,options={},html_options={})
    button_to_function(name, remote_function(options), html_options)
  end
end



