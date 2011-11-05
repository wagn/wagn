module Wagn
 class Renderer::RichHtml < Renderer

  include Recaptcha::ClientHelper

  cattr_accessor :set_actions
  attr_accessor  :options_need_save, :js_queue_initialized,
    :position, :start_time, :skip_autosave

  # This creates a separate class hash in the subclass
  class << self
    def actions() @@set_actions||={} end
  end

  def set_action(key)
    Renderer::RichHtml.actions[key] or super
  end

  def initialize(card, opts=nil)
    super
    @context = "main_1" unless @context =~ /\_/
    @position = @context.split('_').last
    @state = :view
    @renders = {}

    if card and card.collection? and item_param=params[:item]
      @item_view = item_param if !item_param.blank?
    end
  end

### --- render action declarations --- wrapped views are defined for slots

  # these initialize the content of missing builtin layouts
  LAYOUTS = { 'default' => %{
<!DOCTYPE HTML>
<html>
  <head> {{*head|core}} </head>

  <body id="wagn">
    <div id="menu">
      [[/ | Home]]   [[/recent | Recent]]   {{*navbox|core}} {{*account links|core}}
    </div>

    <div id="primary"> {{_main}} </div>

    <div id="secondary">
      <div id="logo">[[/ | {{*logo}}]]</div>
      {{*sidebar|core}}
      <div id="credit"><a href="http://www.wagn.org" title="Wagn {{*version|bare}}">Wagn.</a> We're on it.</div>
      {{*alerts|core}}
    </div>

    {{*foot|core}}
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
    warn "getting layout from name"
    lname = (params[:layout] || args[:layout]).to_s
    lcard = Card.fetch(lname, :skip_virtual=>true, :skip_module_loading=>true)
    case
      when lcard && lcard.ok?(:read)         ; lcard.content
      when hardcoded_layout = LAYOUTS[lname] ; hardcoded_layout
      else  ; "<h1>Unknown layout: #{lname}</h1>Built-in Layouts: #{LAYOUTS.keys.join(', ')}"
    end
  end

  def layout_from_card
    return unless setting_card = (card.setting_card('layout') or Card.default_setting_card('layout'))
    return unless setting_card.is_a?(Wagn::Set::Type::Pointer) and  # type check throwing lots of warnings under cucumber: setting_card.typecode == 'Pointer'        and
      layout_name=setting_card.item_names.first     and
      !layout_name.nil?                             and
      lo_card = Card.fetch(layout_name, :skip_virtual => true, :skip_module_loading=>true)    and
      lo_card.ok?(:read)
    lo_card.content
  end


  def wrap(args = {})
    render_wrap = ( args.key?(:add_slot) ? args.delete(:add_slot) : !skip_outer_wrap_for_ajax? )
    return yield if !render_wrap
    
    css_class = case args[:action].to_s
      when 'content'  ;  'transcluded'
      when 'exception';  'exception'
      when 'closed'   ;  'card-slot line'
      else            ;  'card-slot paragraph'
    end 
    css_class << " " + card.css_names if card
    
    attributes = {
      :class    => css_class,
      :cardId   => (card && card.id),
      :position => generate_position
    }
    [:style, :home_view, :item, :base].each { |key| attributes[key] = args[key] }
    
    
    div( attributes ) { yield }
  end
  
  def generate_position
    UUID.new.generate.gsub(/^(\w+)0-(\w+)-(\w+)-(\w+)-(\w+)/,'\1')
  end

  def skip_outer_wrap_for_ajax?
    # we often skip the outermost slot in ajax calls because the slot is already there.
    ajax_call? && outer_level?
  end

  def wrap_content( content="" )
    %{<span class="#{canonicalize_view(requested_view)}-content content editOnDoubleClick">} +
    content.to_s +
    %{</span>} #<!--[if IE]>&nbsp;<![endif]-->}
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
    (card.new_record? && card.cardname)  ? card.cardname.escape : card.id
  end

  def editor_id(area="")
    area, eid = area.to_s, ""
    eid << context
    eid << (area.blank? ? '' : "-#{area}")
  end

  def edit_submenu(current)
    div(:class=>'submenu') do
      raw(
        [[ :content,    true  ],
         [ :name,       true, ],
         [ :type,       !(card.type_template? || (card.typecode=='Cardtype' && card.cards_of_type_exist?))],
         ].map do |attrib,ok,args|
          if ok
            raw( link_to attrib, "/card/edit/#{card.id}/#{attrib}", :remote=>true,
              :class=>"edit-#{attrib}-link" + (attrib==current ? ' current-submenu-item' : ''))
          end
        end.compact.join
      )
    end
  end

  def options_submenu(on)
    return '' if card && card.extension_type != 'User'
    div(:class=>'submenu') do
      [:account, :settings].map do |key|
        link_to( key, "card/options",# {}, key), :update => id },
          :class=>(key==on ? 'on' : ''), :remote=>true
        )
      end.join
    end
  end

  def url_for(url, args=nil, attribute=nil)
    # recently changed URI.escape to CGI.escape to address question mark issue, but I'm still concerned neither is perfect
    # so long as we keep doing the weird Cardname.escape thing.
    url = "javascript:'/#{url}"
    url << "/#{escape_javascript(CGI.escape(card_id.to_s))}" if (card and card_id)
    url << "/#{attribute}" if attribute
    url << "?context='+getSlotContext(this)"
    url << "+'&' + getSlotOptions(this)"
    url << ("+'"+ args.map{|k,v| "&#{k}=#{escape_javascript(CGI.escape(v.to_s))}"}.join('') + "'") if args
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
    menu.html_safe
    menu
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
=end


  def option( content, args )
    args[:label] ||= args[:name]
    args[:editable]= true unless args.has_key?(:editable)
    self.options_need_save = true if args[:editable]
    %{<tr>
      <td class="inline label"><label for="#{args[:name]}">#{args[:label]}</label></td>
      <td class="inline field">
    } + content + %{
      </td>
      <td class="help">#{args[:help]}</td>
      </tr>
    }
  end

  def option_header(title)
    %{<tr><td colspan="3" class="option-header"><h2>#{title}</h2></td></tr>}
  end

  def link_to_menu_action( to_action)
    klass = { 'edit' => 'edit-content-link'}
    menu_action = (%w{ show update }.member?(action) ? 'view' : action)
    content_tag :li, link_to_action( to_action.capitalize, to_action,
      :class=> "#{klass[to_action]} #{menu_action==to_action ? 'current' : ''}"
    )
  end

  def link_to_action( text, to_action, html_opts={})
    html_opts[:remote] = true
    link_to text, "/card/#{to_action}/#{card.id}", html_opts
  end

  def button_to_action( text, to_action, remote_opts={}, html_opts={})
    if remote_opts.delete(:replace)
      r_opts =  { :url=>url_for("card/#{to_action}", :replace=>id ) }.merge(remote_opts)
    else
      r_opts =  { :url=>url_for("card/#{to_action}" ), :update => id }.merge(remote_opts)
    end
    button_to_remote( text, r_opts, html_opts )
  end

  def name_field(form, options={})
    form.text_field( :name, { 
      :class=>'field card-name-field',
      :value=>card.name, #needed because otherwise gets wrong value if there are updates
      :autocomplete=>'off'
    }.merge(options))
  end

  def typecode_field(form,options={})
    template.select_tag('card[type]', typecode_options_for_select(Cardtype.name_for(card.typecode)), options)
  end

  def content_field(form,options={})
    self.form = form
    @nested = options[:nested]
    pre_content =  (card and !card.new_record?) ? form.hidden_field(:current_revision_id, :class=>'current_revision_id') : ''
    User.as :wagbot do #why wagbot here??
      pre_content + self.render_editor
    end
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
 end
end
