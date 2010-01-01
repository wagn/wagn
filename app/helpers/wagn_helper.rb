require_dependency 'slot'

module WagnHelper
  require_dependency 'wiki_content'

  def slot
    Slot.current_slot
  end
  
  def card
    @card
  end
  
  # FIXME: I think all this slot initialization should happen in controllers
  def get_slot(card=nil, context=nil, action=nil, opts={})
    nil_given = card.nil?
    card ||= @card; context||=@context; action||=@action
    opts[:relative_content] = params  
    slot = case
      when Slot.current_slot;  nil_given ? Slot.current_slot : Slot.current_slot.subslot(card)
      else Slot.current_slot = Slot.new(card,context,action,self,opts)
    end
  end

  # FIMXE: this one's a hack...
  def render_card(card, mode, args={})
    if String===card && name = card
      raise("Card #{name} not present") unless card= (CachedCard.get(name) || Card[name] || Card.find_virtual(name))
    end
    # FIXME: some cases we're called before Slot.current_slot is initialized.
    #  should we initialize here? or always do Slot.new?
    subslot = Slot.current_slot ? Slot.current_slot.subslot(card) : Slot.new(card)
    subslot.render(mode.to_sym, args)
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
    elsif options[:slot] 
      function << Slot.current_slot.url_for(options[:url]).gsub(/^javascript\:/,'')
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
    wordstring.gsub! /<[\/]?br[\s\/]*>/, ' ' ## Also a hack -- get rid of <br>'s -- they make line view ugly.
    wordstring.gsub! /<[\/]?p[^>]*>/, ' ' ## Also a hack -- get rid of <br>'s -- they make line view ugly.
    wordstring
  end

  def symbolize_param(param)
    val = params[param]
    (val && !val.to_s.empty?) ? val.to_sym : nil
  end

  def formal_joint
    " <span class=\"wiki-joint\">#{JOINT}</span> "
  end

  def formal_title(card)
    card.name.split(JOINT).join(formal_joint)
  end

  def less_fancy_title(card)
    name = (String===card ? card : card.name)
    return name if name.simple?
    card_title_span(name.parent_name) + %{<span class="joint">#{JOINT}</span>} + card_title_span(name.tag_name)
  end

  def title_tag_names(card)
    card.name.split(JOINT)
  end


  # Other snippets -------------------------------------------------------------

  def site_title
    System.site_title
  end

  def css_name( name )
    name.gsub(/#{'\\'+JOINT}/,'-').gsub(/[^\w-]+/,'_')
  end

  #def related
  #  render :partial=> 'card/related'
  #end

  #def sidebar
  #  render :partial=>partial_for_action('sidebar', @card)
  #end

  def format_date(date, include_time = true)
    # Must use DateTime because Time doesn't support %e on at least some platforms
    if include_time
      DateTime.new(date.year, date.mon, date.day, date.hour, date.min, date.sec).strftime("%B %e, %Y %H:%M:%S")
    else
      DateTime.new(date.year, date.mon, date.day).strftime("%B %e, %Y")
    end
  end

  ## ----- for Linkers ------------------
  def cardtype_options
    Cardtype.createable_cardtypes.map do |cardtype|
      #next(nil) if cardtype[:codename] == 'User' #or cardtype[:codename] == 'InvitationRequest'
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

  def cardname_auto_complete(fieldname, card_id='')
    content_tag("div", "", :id => "#{fieldname}_auto_complete", :class => "auto_complete") +
    auto_complete_field(fieldname, { :url =>"/card/auto_complete_for_card_name/#{card_id.to_s}" }.update({}))
  end


  def span(*args, &block)  content_tag(:span, *args, &block);  end
  def div(*args, &block)   content_tag(:div, *args, &block);  end

  def pointer_item(content,view,type=nil)
    typeparam = case
      when type.is_a?(String); ";type:#{type}"
      when type.is_a?(Array);  ";type:#{type.second}"  #type spec is likely ["in", "Type1", "Type2"]
      else ""
    end
    content.gsub(/\[\[/,"<div class=\"pointer-item item-#{view}\">{{").gsub(/\]\]/,"|#{view}#{typeparam}}}</div>") 
  end
  
  ## -----------

  def google_analytics
    User.as(:wagbot)  do
      if ga_key = System.setting("*google analytics key")
        %{
          <script type="text/javascript">    
            // make sure this is only run once:  it may be called twice in the case that you are viewing a *layout page
            if (typeof(pageTracker)=='undefined') {
              var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
              document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
            }              
          </script>
          <script type="text/javascript">
            pageTracker = _gat._getTracker('#{ga_key}');
            pageTracker._trackPageview();
          </script>
        }
      end
    end
  end        
  
  # ---------------( NAVBOX ) -----------------------------------    

  def navbox
    content_tag( :form, :id=>"navbox_form", :action=>"/search", :onsubmit=>"return navboxOnSubmit(this)" ) do         
      content_tag( :span, :id=>"navbox_background" ) do
        %{<a id="navbox_image" title="Search" onClick="navboxOnSubmit($('navbox_form'))">&nbsp;</a>}  + text_field_tag("navbox", params[:_keyword] || '', :id=>"navbox_field", :autocomplete=>"off") +
  		    navbox_complete_field('navbox_field') 
      end
    end
	end                                      
    
  def navbox_complete_field(fieldname, card_id='')
    content_tag("div", "", :id => "#{fieldname}_auto_complete", :class => "auto_complete") +
    auto_complete_field(fieldname, { :url =>"/card/auto_complete_for_navbox/#{card_id.to_s}",
      :after_update_element => "navboxAfterUpdate"
     }.update({}))
  end

  def navbox_result(entries, field, stub)
    return unless entries
    items = []
    items << navbox_item( :search, %{<a class="search-icon">&nbsp;</a>Search for: }, stub )
    if !Cardtype.createable_cardtypes.empty? && !CachedCard.exists?(stub)
      items << navbox_item( :new, %{<a class="plus-icon">&nbsp;</a>Add new card: }, stub )
    end
    items += entries.map do |entry| 
      navbox_item( :goto, %{<a class="page-icon">&nbsp;</a>Go to: }, entry[field], stub )
    end
    content_tag("ul", items.uniq)
  end
            
  def navbox_item( css_class, label, name, stub=nil )
    stub ||= name
    content_tag('li', :class=>"#{css_class}" ) do
      content_tag('span', label, :class=>"informal") + highlight(name, stub)
    end
  end
            
  def wagn_form_for(record_or_name_or_array, *args, &proc)
    options = args.extract_options!
  
    case record_or_name_or_array
    when String, Symbol
      object_name = record_or_name_or_array
    when Array
      object = record_or_name_or_array.last
      object_name = ActionController::RecordIdentifier.singular_class_name(object)
      apply_form_for_options!(record_or_name_or_array, options)
      args.unshift object
    else
      object      = record_or_name_or_array
      object_name = ActionController::RecordIdentifier.singular_class_name(record_or_name_or_array)
      apply_form_for_options!(object, options)
      args.unshift object
    end
  
    concat(form_remote_tag(options))
    fields_for(object_name, *(args << options), &proc)
    if args.second[:update]
      concat hidden_field_tag('_update','true')
    end
    concat('</form>')
  end
  
  def layout_card(content)
    Card.new(:name=>"**layout",:content=>content)
  end
  
  def render_layout_card(card)
    Slot.new(card, "layout_0", "view", self, :main_content=>@content_for_layout, :main_card=>@card).render(:naked)
  end  
  
  def render_layout_content(content)
    render_layout_card layout_card(content)
  end
  
  # ------------( helpers ) --------------
  def edit_user_context(card)
    if System.ok?(:administrate_users)
    	'admin'
    elsif current_user == card.extension
    	'user'
    else
    	'public'
    end
  end
end       
