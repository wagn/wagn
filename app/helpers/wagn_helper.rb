module WagnHelper
  require_dependency 'wiki_content'

  Droplet = Struct.new(:name, :link_options)


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
    url_for(opts.merge(
      :action=>'show', 
      :controller=>'card', 
      :id=>Cardname.escape(title), 
      :format => nil
    ))
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
    
  def link_to_footer( text, div_id, card_id, query )
    link_to_remote( text,
				  :update=>"#{div_id}-links",
				  :url => {
					  :controller=>'block', 
					  :action=>'link_list',
					  :id=>card_id,
					  :query=> query 
					},                      
					:method => 'get'  
    )
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
    return card.name if card.simple?
    trunk, tag = card.trunk.name, card.tag.name
    card_title_span(trunk) + %{<span class="joint">#{JOINT}</span>} + card_title_span(tag)
  end
  
  def card_title_span( title )
    %{<span class="title-#{css_name(title)} card">#{title}</span>}
  end
  
  def card_function( element, name, *args )
    #quoted_args = args.collect {|arg| "'#{arg}'" }.join(',')
    "$('#{element}').card().#{name.to_s}(#{args.join(',')}); return false;"
  end
  
  def inner_card_function( name, *args )
    "Wagn.CardTable[ this.parentNode.parentNode.parentNode.parentNode.id ].#{name.to_s}(#{args.join(',')})"
  end
  
  def connector_function( name, *args )
    "Wagn.lister().#{name.to_s}(#{args.join(',')});"
  end             
  
  def card_attribute_function( attr_name )
    card_function(params[:element], :update_attribute, "'#{attr_name}'", '$F(this)') 
  end
  
  
  # Forms --------------------------------------------------------
  def form_for_block( options={}, form_options={} )
    ajax = options.has_key?(:ajax) ? options[:ajax] : true
    url_options = options_for_block( options )
    element = url_options[:params][:element]
    
    if ajax
      form_remote_tag(
        { :url => url_options,
          :html => { :name => 'block_form' },
          :update => { :success=> element, :failure => element }
        }.merge(form_options)
      )
    else
      form_tag url_options.merge(form_options)
    end
  end

  def options_for_ajax_or_page( params )
    options = { :controller=>params.delete(:controller),
        :action => params.delete(:action),
        :id => params.delete(:id),
        :params => params
    }
    options
  end
  
  def options_for_block( options={} )
    params = {
      :controller => 'block',
      :action => 'connection_list',
      :ajax => true,
      :card => @card
    }.merge(options)
    
    params[:id] = params.delete(:card).id if params[:card]
    options_for_ajax_or_page( params )
  end

  # Common image tags
  
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
    # FIXME?: some requests, like /options/roles (which would normally only be called as ajax)
    # do have a card, but it's definitely weird to have a Related cards underneath.  but it's 
    # weird to call those directly anyway, so not a big deal.
    return '' unless @card and @card.id and controller.controller_name=='card'
    render :partial=> 'card/related'
  end
  
  def sidebar
	  render :partial=>'block/card_list', :locals=>{ :cards=>renderer.sidebar_cards(), :context=>'sidebar' }
  end

  def format_date(date, include_time = true)
    # Must use DateTime because Time doesn't support %e on at least some platforms
    if include_time
      DateTime.new(date.year, date.mon, date.day, date.hour, date.min, date.sec).strftime("%B %e, %Y %H:%M:%S")
    else
      DateTime.new(date.year, date.mon, date.day).strftime("%B %e, %Y")
    end
  end
  
  def get_partial( card, context, element )
    basic = 'line'
    ext = context
    if context=='sidebar' 
      if  ( card.template.attribute_card('*open') or 
         (!card.simple? and card.tag.plus_sidebar and card.tag.attribute_card('*open')))
        basic = "paragraph"
      end
    end
    "#{basic} #{ext}"
  end
  
  def get_div_id( card, context, element="" )
    div_id = element.clone
    div_id << '-' unless div_id.empty?                              
    # risk duplication within a context (we should check for that somehow)
    # but enables cacheing (of footers in particular)
    div_id << context + '-' + card.id.to_s # + '-' + rand(1000).to_s
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
        when 'Role';       next unless System.ok? :manage_permissions
        when 'Cardtype';   next unless System.ok? :edit_cardtypes
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

  def partial_for_card_and_action( card, action )                              
    if file_exists? "/card/#{card.class_name.underscore}/_#{action}"
      "/card/#{card.class_name.underscore}/#{action}" 
    else
      "/card/basic/#{action}"
    end
  end  

end



