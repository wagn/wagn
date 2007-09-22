module WagnHelper
  require_dependency 'wiki_content'

  Droplet = Struct.new(:name, :link_options)     
  
  class Slot
    
    attr_reader :card, :context, :action, :renderer, :template
    attr_accessor :form, :editor_count, :options_need_save, :transclusion_mode,
      :transclusions, :position, :renderer, :form
    def initialize(card, context, action, template, renderer=nil )
      @card, @context, @action, @template, @renderer= card, context.to_s, action.to_s, template,renderer
      raise("context gotta include position") unless context =~ /\:/
      @position = context.split(':').last
      @subslots = []  
      @transclusion_mode = 'view'
      @renderer ||= Renderer.new(self)
    end

    def id(area="") 
      area, id = area.to_s, ""  
      id << "javascript:elem=#{get(area)}"
    end                         
     
    def nested_context?
      context.split(':').length > 2
    end
     
    def get(area="")
      area.empty? ? "getSlotSpan(this)" : "getSlotElement(this, '#{area}')"
    end
     
    def selector(area="")
      positions = context.split(':')
      outer_context = positions.shift # first one is id
      selector = "#" + outer_context
      while pos = positions.shift
        selector << " span[position=#{pos}]"
      end   
      if !area.empty?
        selector << " .#{area}"
      end
      selector
    end

    def editor_id(area="")
      area, eid = area.to_s, ""
      eid << context
      eid << (area.blank? ? '' : "-#{area}")
    end

    def url_for(url)
      url = "javascript:'/#{url}" 
      url << "/#{card.id}" if (card and card.id)
      url << "?context='+getSlotContext(this)"
    end

    def method_missing(method_id, *args, &proc)
      @template.send("slot_#{method_id}", self, *args, &proc)
    end 
    
    def render( card, mode=:view, args={} )
      oldmode, @transclusion_mode = @transclusion_mode, mode
      result = @renderer.render( card, args.delete(:content) || "", update_refs=false)
      @transclusion_mode = oldmode
      result
    end

    def subslot(card, &proc)
      # Note that at this point the subslot context, and thus id, are
      # somewhat meaningless-- the subslot is only really used for tracking position.
      new_slot = self.class.new(card, context+":#{@subslots.size+1}", @action, @template, @renderer)
      @subslots << new_slot 
                                     
      # NOTE this code is largely copied out of rails fields_for
      options = {} # do I need any? #args.last.is_a?(Hash) ? args.pop : {}
      object_name = "cards[#{card.id}]"
      object  = card 
      block = Proc.new {}
      
      builder = options[:builder] || ActionView::Base.default_form_builder
      fields_for = builder.new(object_name, object, @template, options, block)       
      new_slot.form = fields_for
      new_slot.position = @subslots.size
 
      new_slot
#      old_slot, @template.controller.slot = @template.controller.slot, new_slot
#      result = yield(new_slot)
#      @template.controller.slot = old_slot
#      result
    end
    
    def render_transclusion( card, *args )    
      new_slot = subslot(card)  
      old_slot, @template.controller.slot = @template.controller.slot, new_slot  
      result = new_slot.send("render_transclusion_#{@transclusion_mode}", *args)
      @template.controller.slot = old_slot
      result
    end   
    
    def render_transclusion_view( options={} )   
      #return "TRANSCLUDING #{card.name}"
      if card.new_record? 
        %{<span class="faint createOnClick" position="#{position}" cardid="" cardname="#{card.name}">}+
          %{Click to create #{card.name}</span>}
      elsif options[:view]=='raw'
        card.content
      elsif options[:view]=='card' 
        @action = 'view'
        @template.render :partial=>'/card/view', :locals=>{ :card=>card,:render_slot=>true }
      elsif options[:view]=='line'
        @action = 'line'
        @template.render :partial=>'/card/line', :locals=>{ :card=>card, :render_slot=>true }
      else #options['view']=='content' -- default case
        @action='transclusion'
        @template.render :partial=>'/transclusion/view', :locals=>{ :card=>card, :render_slot=>true }
      end   
    end
    
    def render_transclusion_edit( options={} )
      if card.new_record?
        %{<span class="faint" position="#{position}" cardid="" cardname="#{card.name}">}+
          %{(#{card.name} would go here.)</span>}
      else
        %{<div class="edit-area">} +
          %{<span class="title">#{@template.less_fancy_title(card)}</span> } + 
          content_field( form, :nested=>true ) +
          "</div>"
      end
    end
          
    def render_transclusion_line(options={})        
      render_transclusion_view( :view=>'transclusion' )
    end
        
    def render_diff(card, *args)
      @renderer.render_diff(card, *args)
    end
       
    
    def head
      css_class = 'card-slot '      
      if action=='line'  
        css_class << 'line' 
      else
        css_class << 'paragraph'                     
      end
      css_class << ' full' if (context=~/main/ or (action!='view' and action!='line'))
      css_class << ' sidebar' if context=~/sidebar/
      css_class = 'transcluded' if action=='transclusion'
      css_class << " cardid-#{card.id}" if card

      id_attr = card ? %{cardId="#{card.id}"} : ''
      head = %{<span #{id_attr} class="#{css_class}" position="#{position}" >}
    end
    
    def foot
      "</span>"
    end
    
    def wrap(*args, &proc)
      @template.concat(head, proc.binding)
      yield(self)
      @template.concat(foot, proc.binding)
    end
      
    def content_head
      %{<span class="content editOnDoubleClick">} 
    end
    def content_foot
      %{</span>} 
    end
    
    def wrap_content( content="" )
      content_head + content + content_foot
    end
  end

  
  # For cases where you just need to grab a quick id or so..
  def slot
    controller.slot ||= Slot.new(@card,@context,@action,self)
  end
  
  def with_slot( card, context, action, options={}, &proc) 
    new_slot = Slot.new(card,context,action,self)
    old_slot, controller.slot = controller.slot, new_slot
    yield new_slot #slot_for(card, context, action, options={}, &proc)
    controller.slot = old_slot
  end
    
  def slot_for( card, context, action, options={}, &proc )
    @action  = action
    options[:render_slot] = !request.xhr? if options[:render_slot].nil?            
    if options[:render_slot]    
      slot.wrap(&proc)
    else
      yield slot
    end
  end 
  
  def slot_rendered_content( slot, card )   
    c, name = controller, "card/content/#{card.id}"
    if c.perform_caching and card.cacheable? and content = c.read_fragment(name)
      return content
    end
    content = render :partial=>partial_for_action("content", card),
                :locals=>{:card=>card, :slot=>slot}
    if card.cacheable? and c.perform_caching
      c.write_fragment(name, content)
    end
    content
  end

  def slot_notice(slot)
    %{<span class="notice">#{controller.notice}</span>}
  end

  def slot_header(slot)
    render :partial=>'card/header', :locals=>{ :card=>slot.card, :slot=>slot }
  end
  
  def slot_menu(slot)
    menu = %{<div class="card-menu">\n}
  	menu << slot.link_to_menu_action('view')
  	if slot.card.ok?(:edit) 
    	menu << slot.link_to_menu_action('edit')
  	else
  	  menu << link_to_remote("Edit", :url=>slot.url_for('card/denied'), :update=>slot.id)
	  end
  	menu << slot.link_to_menu_action('changes')
  	menu << slot.link_to_menu_action('options')
    menu << "</div>"
  end

  def slot_footer(slot)
    controller.send :render_to_string, :partial=>"card/footer", :locals=>{ :card=>slot.card, :slot=>slot }
  end
  
  def slot_option(slot, args={}, &proc)
    args[:label] ||= args[:name]
    args[:editable]= true unless args.has_key?(:editable)
    slot.options_need_save = true if args[:editable]
    concat %{<tr>
      <td class="inline label"><label for="#{args[:name]}">#{args[:label]}</label></td>
      <td class="inline field">
    }, proc.binding
    yield
    concat %{
      </td>
      <td class="help">#{args[:help]}</td>
      </tr>
    }, proc.binding
  end

  def slot_option_header(title)
    %{<tr><td colspan="3" class="option-header"><h2>#{title}</h2></td></tr>}
  end


  def slot_link_to_action(slot, text, to_action, remote_opts={}, html_opts={})
    link_to_remote text, remote_opts.merge(
      :url=>slot.url_for("card/#{to_action}"),
      :update => slot.id
    ), html_opts
  end

  def slot_button_to_action(slot, text, to_action, remote_opts={}, html_opts={})
    button_to_remote text, remote_opts.merge(
      :url=>slot.url_for("card/#{to_action}"),
      :update => slot.id
    ), html_opts
  end
  
  
  def slot_link_to_menu_action(slot, to_action)
    slot.link_to_action to_action.capitalize, to_action, {},
      :class=> (slot.action==to_action ? 'current' : '')
  end
       
  def slot_render_partial(slot, partial, args={})
    # FIXME: this should look up the inheritance hierarchy, once we have one      
    args[:card] ||= slot.card
    args[:slot] =slot
    render :partial=> partial_for_action(partial, args[:card]), :locals => args
  end
  
  def slot_name_field(slot,form,options={})
    text = %{<span class="label"> card name:</span>\n}
    text << form.text_field( :name, options.merge(:size=>40, :class=>'field card-name-field'))
  end
  
  def slot_cardtype_field(slot,form,options={})
    card = options[:card] ? options[:card] : slot.card
    text = %{<span class="label"> card type:</span>\n} 
    text << select_tag('card[type]', cardtype_options_for_select(card.type), options) 
  end
  
  def slot_update_cardtype_function(slot,options={})
    fn = ['File','Image'].include?(slot.card.type) ? 
            "Wagn.onSaveQueue['#{slot.context}'].clear(); " :
            "Wagn.runQueue(Wagn.onSaveQueue['#{slot.context}']); "      
    if @card.hard_content_template
      #options.delete(:with)
    end
    fn << remote_function( options )   
  end
       
  def slot_js_content_element(slot)
    @card.hard_content_template ? "" : ",getSlotElement(this,'form').elements['card[content]']" 
  end
  
  def slot_content_field(slot,form,options={})   
    slot.form = form              
    @nested = options[:nested]
    pre_content = (slot.card and !slot.card.new_record?) ? form.hidden_field(:current_revision_id, :class=>'current_revision_id') : ''
    pre_content + slot.render_partial( 'editor', options )
  end                          
         
  def slot_save_function(slot)
    "warn('runnint #{slot.context} queue'); if (Wagn.runQueue(Wagn.onSaveQueue['#{slot.context}'])) { this.form.onsubmit() }"
  end
  
  def slot_cancel_function(slot)
    "Wagn.runQueue(Wagn.onCancelQueue['#{slot.context}']);"
  end
  

  def slot_editor_hooks(slot,hooks)
    # it seems as though code executed inline on ajax requests works fine
    # to initialize the editor, but when loading a full page it fails-- so
    # we run it in an onLoad queue.  the rest of this code we always run
    # inline-- at least until that causes problems.     
    hook_context = @nested ? slot.context.split(':')[0..-2].join(':') : slot.context
    
    code = ""
    if hooks[:setup]
      code << "Wagn.onLoadQueue.push(function(){\n" unless request.xhr?
      code << hooks[:setup]
      code << "});\n" unless request.xhr?
    end
    if hooks[:save]  
      code << "warn('adding to #{hook_context} save queue');"
      code << "if (typeof(Wagn.onSaveQueue['#{hook_context}'])=='undefined') {\n"
      code << "  Wagn.onSaveQueue['#{hook_context}']=$A([]);\n"
      code << "}\n"
      code << "Wagn.onSaveQueue['#{hook_context}'].push(function(){\n"
      code << "warn('running #{hook_context} save hook');"
      code << hooks[:save]
      code << "});\n"
    end
    if hooks[:cancel]
      code << "if (typeof(Wagn.onCancelQueue['#{hook_context}'])=='undefined') {\n"
      code << "  Wagn.onCancelQueue['#{hook_context}']=$A([]);\n"
      code << "}\n"
      code << "Wagn.onCancelQueue['#{hook_context}'].push(function(){\n"
      code << hooks[:cancel]
      code << "});\n"
    end
    javascript_tag code
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
      update << "success:'#{options[:update][:success]}'" if options[:update][:success]
      update << "failure:'#{options[:update][:failure]}'" if options[:update][:failure]
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
  
  def truncatewords_with_closing_tags(input, words = 15, truncate_string = "...")
    if input.nil? then return end
    wordlist = input.to_s.split
    l = words.to_i - 1
    l = 0 if l < 0
    wordstring = wordlist.length > l ? wordlist[0..l].join(" ") : input     
    # nuke partial tags at end of snippet
    wordstring.gsub!(/(<[^\>]+)$/,'')
    h1 = {}
    h2 = {}        
    # match tags with or without self closing (ie. <foo />)
    wordstring.scan(/\<([^\>\s\/]+)[^\>]*?\>/).each { |t| h1[t[0]] ? h1[t[0]] += 1 : h1[t[0]] = 1 }
    # match tags with self closing and mark them as closed
    wordstring.scan(/\<([^\>\s\/]+)[^\>]*?\/\>/).each { |t| h2[t[0]] ? h2[t[0]] += 1 : h2[t[0]] = 1 }
    # match close tags
    wordstring.scan(/\<\/([^\>\s\/]+)[^\>]*?\>/).each { |t| h2[t[0]] ? h2[t[0]] += 1 : h2[t[0]] = 1 }
    h1.keys.reverse.each {|k| v=h1[k]; wordstring += "</#{k}>" * (h1[k] - h2[k].to_i) if h2[k].to_i < v }
    ###  HAAAAAAAAACK.  FIXME NIXME or else you's can licks me.  Reversing the key order on a hash?  Am I shitting me? 
    
    wordstring +='<span style="color:#666"> ...</span>' if wordlist.length > l    
#    wordstring += '...' if wordlist.length > l    
    wordstring.gsub! /<br[\s\/]*>/, ' ' ## Also a hack -- get rid of <br>'s -- they make line view ugly.
    wordstring
  end

  # You'd think we'd want to use this one but it sure doesn't seem to work as
  # well as the truncatewords...
=begin
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
=end 
   
  def conditional_cache(card, name, &block)
    card.cacheable? ? controller.cache_erb_fragment(block, name) : block.call
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
    "/wagn/#{Cardname.escape(title)}"
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
  
  def page_icon (card)
    link_to_page image_tag('page.png', :title=>"Card Page for: #{card.name}"), card.name
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
    session[:createable_cardtypes]
  end
    

  ## ----- for Linkers ------------------  
  def cardtype_options
    User.current_user.createable_cardtypes.map do |cardtype|
      next if cardtype[:codename] == 'User' #or cardtype[:codename] == 'InvitationRequest'
      [cardtype[:codename], cardtype[:name]]
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
  
  
  def stylesheet_inline(name)
    out = %{<style type="text/css" media="screen">\n}
    out << File.read("#{RAILS_ROOT}/public/stylesheets/#{name}.css")
    out << "</style>\n"
  end
  
end



