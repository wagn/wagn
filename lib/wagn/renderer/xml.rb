module Wagn
 class Renderer::Xml < Renderer

  LAYOUTS = { 'default' => %{
<carddoc>
{{_main}}
</carddoc>
} }

  cattr_accessor :set_actions
  attr_accessor  :options_need_save, :js_queue_initialized,
    :position, :start_time, :skip_autosave

  # This creates a separate class hash in the subclass
  class << self
    def actions() @@set_actions||={} end
  end

  def set_action(key)
    Renderer::Xml.actions[key] or super
  end

  def initialize(card, opts=nil)
    super
    @context = "main_1" unless @context =~ /\_/
    @position = @context.split('_').last
    @state = :view
    @renders = {}
    @js_queue_initialized = {}

    if card and card.collection? and item_param=params[:item]
      @item_view = item_param if !item_param.blank?
    end
  end

  def build_link(href, text)
    klass = case href
      when /^https?:/; 'external-link'
      when /^mailto:/; 'email-link'
      when /^\//
        href = full_uri(href)
        'internal-link'
      else
        known_card = !!Card.fetch(href)
        text = text.to_show(href)
        href = '/wagn/' + (known_card ? href.to_url_key : CGI.escape(Wagn::Cardname.escape(href)))
        href = full_uri(href)
        return %{<cardlink class="#{
                    known_card ? 'known-card' : 'wanted-card'
                  }" card="#{href}">#{text}</cardlink>}
      end
    %{<link class="#{klass}" href="#{href}">#{text}</link>}
  end   
          
  def wrap(args = {})
    css_class = case args[:action].to_s
      when 'content'  ;  'transcluded'
      when 'exception';  'exception'
      when 'closed'   ;  'card-slot line'
      else            ;  'card-slot paragraph'
    end 
    css_class << " " + Wagn::Pattern.css_names( card ) if card
    
    attributes = {
      :name => card.name.tag_name,
      :cardId   => (card && card.id),
      :type     => card.typecode,
      :class    => css_class,
    }
    [:style, :home_view, :item, :base].each { |key| attributes[key] = args[key] }
    
    content_tag(:card, attributes ) { yield }
  end

  def get_layout_content(args)
    User.as(:wagbot) do
      case
        when (params[:layout] || args[:layout]) ;  layout_from_name
        when card                               ;  layout_from_card
        else                                    ;  LAYOUTS['default']
      end
    end
  end

  def layout_from_name
    lname = (params[:layout] || args[:layout]).to_s
    lcard = Card.fetch(lname, :skip_virtual=>true)
    case
      when lcard && lcard.ok?(:read)         ; lcard.content
      when hardcoded_layout = LAYOUTS[lname] ; hardcoded_layout
      else  ; "<h1>Unknown layout: #{lname}</h1>Built-in Layouts: #{LAYOUTS.keys.join(', ')}"
    end
  end

  def layout_from_card
    return unless setting_card = (card.setting_card('layout') or Card.default_setting_card('layout'))
    return unless setting_card.typecode == 'Pointer'           and
      layout_name=setting_card.item_names.first                and
      !layout_name.nil?                                        and
      lo_card = Card.fetch(layout_name, :skip_virtual => true) and
      lo_card.ok?(:read)
    lo_card.content
  end


=begin
  # these initialize the content of missing builtin layouts
  LAYOUTS = { 'default' => %{
<!DOCTYPE HTML>
<html>
  <head> {{*head|naked}} </head>

  <body id="wagn">
    <div id="menu">
      [[/ | Home]]   [[/recent | Recent]]   {{*navbox|naked}} {{*account links|naked}}
    </div>

    <div id="primary"> {{_main}} </div>

    <div id="secondary">
      <div id="logo">[[/ | {{*logo}}]]</div>
      {{*sidebar|naked}}
      <div id="credit"><a href="http://www.wagn.org" title="Wagn {{*version|bare}}">Wagn.</a> We're on it.</div>
      {{*alerts|naked}}
    </div>

    {{*foot|naked}}
  </body>
</html> },

        'blank' => %{
<!DOCTYPE HTML>
<html>
  <head> {{*head}} </head>
  <body id="wagn"> {{_main}} {{*foot}} </body>
</html> },

        'simple' => %{
<!DOCTYPE HTML>
<html>
  <head> {{*head}} </head>
  <body> {{_main}} {{*foot}} </body>
</html> },

        'none' => '{{_main}}',

        'noside' => %{
<!DOCTYPE HTML>
<html>
  <head> {{*head}} </head>

  <body id="wagn" class="noside">
    <div id="menu">
      [[/ | Home]]   [[/recent | Recent]]   {{*navbox}} {{*account links}}
    </div>

    <div>
      {{*alerts}}
      {{_main}}
      <div id="credit">Wheeled by [[http://www.wagn.org|Wagn]] v. {{*version}}</div>
    </div>

    {{*foot}}
  </body>
</html> },

        'pre' => %{
<!DOCTYPE HTML>
<html> <body><pre>{{_main|raw}}</pre></body> </html> },

 }






  def js
    @js ||= SlotJavascript.new(self)
  end

  # FIXME: passing a block seems to only work in the templates and not from
  # internal slot calls, so I added the option passing internal content which
  # makes all the ugly block_given? ifs..

  def skip_outer_wrap_for_ajax?
    # we often skip the outermost slot in ajax calls because the slot is already there.
    ajax_call? && outer_level?
  end

  def wrap_main(content)
    return content if p=root.params and p[:layout]=='none'
    %{<div id="main" context="main">#{content}</div>}
  end

  #### --------------------  additional helpers ---------------- ###
  def notice
    # this used to access controller.notice, but as near I can tell
    # nothing ever assigns to controller.notice, so I took it away.
    # entries in flash[:notice] would be more appropriate in the page-wide
    # alert area. a quick javascript hack to have this put them there resulted in
    # odd behavior so leaving it off for now -LWH
    %{<span class="notice"></span>}
  end

  def id(area="")
    area, id = area.to_s, ""
    id << "javascript:#{get(area)}"
  end

  def parent
    "javascript:getSlotSpan(getSlotSpan(this).parentNode)"
  end

  def nested_context?
    context.split('_').length > 2
  end

  def get(area="")
    area.empty? ? "getSlotSpan(this)" : "getSlotElement(this, '#{area}')"
  end

  def selector(area="")
    "getSlotFromContext('#{context}')";
  end

  def card_id
    (card.new_record? && card.name)  ? Cardname.escape(card.name) : card.id
  end

  def editor_id(area="")
    area, eid = area.to_s, ""
    eid << context
    eid << (area.blank? ? '' : "-#{area}")
  end

  def edit_submenu(on)
    div(:class=>'submenu') do
      [[ :content,    true  ],
       [ :name,       true, ],
       [ :type,       !(card.type_template? || (card.typecode=='Cardtype' and ct=card.me_type and !ct.find_all_by_trash(false).empty?))],
       [ :codename,   (System.always_ok? && card.typecode=='Cardtype')],
       [ :inclusions, !(card.out_transclusions.empty? || card.template? || card.hard_template),         {:inclusions=>true} ]
       ].map do |key,ok,args|

        link_to_remote( key,
          { :url=>url_for("card/edit", args, key), :update => ([:name,:type,:codename].member?(key) ? id('card-body') : id) },
          :class=>(key==on ? 'on' : '')
        ) if ok
      end.compact.join
     end
  end

  def options_submenu(on)
    div(:class=>'submenu') do
      [:permissions, :settings].map do |key|
        link_to_remote( key,
          { :url=>url_for("card/options", {}, key), :update => id },
          :class=>(key==on ? 'on' : '')
        )
      end.join
    end
  end

  def url_for(url, args=nil, attribute=nil)
    # recently changed URI.escape to CGI.escape to address question mark issue, but I'm still concerned neither is perfect
    # so long as we keep doing the weird Cardname.escape thing.
    url = "#{url}"
    url << "/#{CGI.escape(card_id.to_s)}" if (card and card_id)
    url << "/#{attribute}" if attribute
    url << ("+'"+ args.map{|k,v| "&#{k}=#{CGI.escape(v.to_s)}"}*'' + "'") if args
    url
  end

  def header
    render_partial('card/header')
  end
  
  def footer
    render_partial('card/footer')
  end

  def menu
    if card.virtual?
      return %{<span class="card-menu faint">Virtual</span>\n}
    end
    menu_options = [:view,:changes,:options,:related,:edit]
    top_option = menu_options.pop
    menu = %{<span class="card-menu">\n}
      menu << %{<span class="card-menu-left">\n}
        menu_options.each do |opt|
          menu << link_to_menu_action(opt.to_s)
        end
      menu << "</span>"
      menu << link_to_menu_action(top_option.to_s)
    menu << "</span>"
  end

=begin
  def footer
    #render_partial 'card/footer'
    render_footer
  end

  def footer_links
    #render_partial( 'card/footer_links' )   # this is ugly reusing this cache code
    render_footer_links
  end
#=end

  def option( *args, &proc)
    args = args[0]||{} #unless Hash===args
    args[:label] ||= args[:name]
    args[:editable]= true unless args.has_key?(:editable)
    self.options_need_save = true if args[:editable]
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

  def option_header(title)
    %{<tr><td colspan="3" class="option-header"><h2>#{title}</h2></td></tr>}
  end

  def link_to_menu_action( to_action)
    menu_action = (%w{ show update }.member?(action) ? 'view' : action)
    content_tag( :li, link_to_action( to_action.capitalize, to_action, {} ),
      :class=> (menu_action==to_action ? 'current' : ''))
  end

  def link_to_action( text, to_action, remote_opts={}, html_opts={})
    link_to_remote text, {
      :url=>url_for("card/#{to_action}", remote_opts),
      :update => id
    }.merge(remote_opts), html_opts
  end

  def button_to_action( text, to_action, remote_opts={}, html_opts={})
    if remote_opts.delete(:replace)
      r_opts =  { :url=>url_for("card/#{to_action}", :replace=>id ) }.merge(remote_opts)
    else
      r_opts =  { :url=>url_for("card/#{to_action}" ), :update => id }.merge(remote_opts)
    end
    button_to_remote( text, r_opts, html_opts )
  end

  def name_field(form,options={})
    form.text_field( :name, { :class=>'field card-name-field', :autocomplete=>'off'}.merge(options))
  end

  def cardtype_field(form,options={})
    template.select_tag('card[type]', cardtype_options_for_select(Cardtype.name_for(card.typecode)), options)
  end

  def update_cardtype_function(options={})
    fn = ['File','Image'].include?(card.typecode) ?
            "Wagn.onSaveQueue['#{context}']=[];" :
            "Wagn.runQueue(Wagn.onSaveQueue['#{context}']); "
    fn << remote_function( options )
  end

  def js_content_element
    @card.hard_template ? "" : ",getSlotElement(this,'form').elements['card[content]']"
  end

  def content_field(form,options={})
    self.form = form
    @nested = options[:nested]
    pre_content =  (card and !card.new_record?) ? form.hidden_field(:current_revision_id, :class=>'current_revision_id') : ''
    User.as :wagbot do
      pre_content + clear_queues + self.render_editor + setup_autosave
    end
  end

  def clear_queues
    queue_context = get_queue_context

    return '' if root.js_queue_initialized.has_key?(queue_context)
    root.js_queue_initialized[queue_context]=true

    javascript_tag(
      "Wagn.onSaveQueue['#{queue_context}']=[];\n"+
      "Wagn.onCancelQueue['#{queue_context}']=[];"
    )
  end


  def save_function
    "if(ds=Wagn.draftSavers['#{context}']){ds.stop()}; if (Wagn.runQueue(Wagn.onSaveQueue['#{context}'])) { } else {return false}"
  end

  def cancel_function
    "if(ds=Wagn.draftSavers['#{context}']){ds.stop()}; Wagn.runQueue(Wagn.onCancelQueue['#{context}']);"
  end

  def get_queue_context
    #FIXME: this looks like it won't work for arbitraritly nested forms.  1-level only
    @nested ? context.split('_')[0..-2].join('_') : context
  end

  def editor_hooks(hooks)
    # it seems as though code executed inline on ajax requests works fine
    # to initialize the editor, but when loading a full page it fails-- so
    # we run it in an onLoad queue.  the rest of this code we always run
    # inline-- at least until that causes problems.

    queue_context = get_queue_context
    code = ""
    if hooks[:setup]
      code << "Wagn.onLoadQueue.push(function(){\n" unless ajax_call?
      code << hooks[:setup]
      code << "});\n" unless ajax_call?
    end
    if hooks[:save]
      code << "Wagn.onSaveQueue['#{queue_context}'].push(function(){\n #{hooks[:save]} \n });\n"
    end
    if hooks[:cancel]
      code << "Wagn.onCancelQueue['#{queue_context}'].push(function(){\n #{hooks[:cancel]} \n });\n"
    end
    javascript_tag code
  end

  def open_close_js(js_method)
    return '' if !ajax_call? || @depth!=0
    javascript_tag %{Wagn.#{js_method}(getSlotFromContext('#{params[:context]}'))}
  end

  def setup_autosave
    return '' if @nested or @skip_autosave
    javascript_tag "Wagn.setupAutosave('#{card.id}', '#{context}');\n"
  end


  def captcha_tags(opts={})
    return unless controller && controller.captcha_required?
    return "Captcha turned on but no RECAPTCHA key configured" unless recaptcha_key = ENV['RECAPTCHA_PUBLIC_KEY']
    
    js_lib_uri = "http://api.recaptcha.net/js/recaptcha_ajax.js"
    card_key = card.new_record? ? "new" : card.key
    recaptcha_tags( :ajax=>true, :display=>{:theme=>'white'}, :id=>card_key) +
    javascript_tag(
      opts[:full] ?
        %{jQuery.getScript("#{js_lib_uri}", function(){
            document.getElementById('dynamic_recaptcha-#{card_key}').innerHTML='<span class="faint">loading captcha</span>';
            Recaptcha.create('#{recaptcha_key}', document.getElementById('dynamic_recaptcha-#{card_key}'),RecaptchaOptions);
          });
        } :
        %{loadScript("#{js_lib_uri}")}
    )
  end
=end
 end
end
