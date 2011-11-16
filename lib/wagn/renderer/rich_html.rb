module Wagn
  class Renderer::RichHtml < Renderer

    include Recaptcha::ClientHelper

    cattr_accessor :set_actions
    attr_accessor  :options_need_save, :js_queue_initialized, :start_time, :skip_autosave

    # This creates a separate class hash in the subclass
    class << self
      def actions() @@set_actions||={} end
    end

    def set_action(key)
      Renderer::RichHtml.actions[key] or super
    end

    def initialize(card, opts=nil)
      super
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
      lname = (params[:layout] || args[:layout]).to_s
      lcard = Card.fetch(lname, :skip_virtual=>true, :skip_modules=>true)
      case
        when lcard && lcard.ok?(:read)         ; lcard.content
        when hardcoded_layout = LAYOUTS[lname] ; hardcoded_layout
        else  ; "<h1>Unknown layout: #{lname}</h1>Built-in Layouts: #{LAYOUTS.keys.join(', ')}"
      end
    end

    def layout_from_card
      return unless setting_card = (card.setting_card('layout') or Card.default_setting_card('layout'))
      return unless setting_card.is_a?(Wagn::Set::Type::Pointer) and  # type check throwing lots of warnings under cucumber: setting_card.typecode == 'Pointer'        and
        layout_name=setting_card.item_names.first                and
        !layout_name.nil?                                        and
        lo_card = Card.fetch( layout_name, :skip_virtual => true, :skip_modules=>true )    and
        lo_card.ok?(:read)
      lo_card.content
    end


    def wrap(view, args = {})
      classes = ['card-slot', "#{view}-view"]
      classes << card.css_names if card
    
      attributes = { :class => classes.join(' ') }
      [:style, :home_view, :item, :base].each { |key| attributes[key] = args[key] }
    
      div( attributes ) { yield }
    end

    def wrap_content( view, content="" )
      %{
        <span class="#{view}-content content editOnDoubleClick">
          #{content.to_s}
        </span>
       }
    end

    def wrap_main(content)
      return content if p=root.params and p[:layout]=='none'
      %{<div id="main">#{content}</div>}
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

    def card_id
      (card.new_record? && card.cardname)  ? card.cardname.escape : card.id
    end

    def edit_submenu(current)
      extra_css_classes = { :content => 'init-editors' }
      div(:class=>'submenu') do
        [[ :content,    true  ],
         [ :name,       true, ],
         [ :type,       !(card.type_template? || (card.typecode=='Cardtype' && card.cards_of_type_exist?))],
         ].map do |attrib,ok,args|
          if ok
            raw( link_to attrib, "/card/edit/#{card.id}/#{attrib}", :remote=>true,
              :class=>"standard-slotter edit-#{attrib}-link #{extra_css_classes[attrib]}" + 
                (attrib==current ? ' current-subtab' : ''))
          end
        end.compact.join
      end
    end

    def options_submenu(current)
      return '' if card && card.extension_type != 'User'
      div(:class=>'submenu') do
        raw(
          [:account, :settings].map do |key|
            link_to( key, "/card/options/#{card.id}/#{key}",
              :class=>'standard-slotter' + (key==current ? ' current-subtab' : ''), :remote=>true
            )
          end.join
        )
      end
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


    def option( content, args )
      args[:label] ||= args[:name]
      args[:editable]= true unless args.has_key?(:editable)
      self.options_need_save = true if args[:editable]
      raw %{<tr>
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
      klass = { 'edit' => 'edit-content-link init-editors'}
      menu_action = (%w{ show update }.member?(to_action) ? 'view' : to_action)
      content_tag :li, link_to_action( to_action.capitalize, to_action,
        :class=> "standard-slotter #{klass[to_action]} #{menu_action==to_action ? ' current' : ''}"
      )
    end

    def link_to_action( text, to_action, html_opts={})
      html_opts[:remote] = true
      link_to text, "/card/#{to_action}/#{card.id}", html_opts
    end

    def name_field(form, options={})
      form.text_field( :name, { 
        :class=>'field card-name-field',
        :value=>card.name, #needed because otherwise gets wrong value if there are updates
        :autocomplete=>'off'
      }.merge(options))
    end

    def typecode_field(options={})
      typename = card ? Cardtype.name_for(card.typecode) : ''
      template.select_tag('card[type]', typecode_options_for_select( typename ), options)
    end

    def content_field(form,options={})
      self.form = form
      @nested = options[:nested]
      pre_content =  (card and !card.new_record?) ? form.hidden_field(:current_revision_id, :class=>'current_revision_id') : ''
      User.as :wagbot do #why wagbot here??
        pre_content + self.render_editor
      end
    end
    
    def form_for_multi
      block = Proc.new {}
      builder = ActionView::Base.default_form_builder
      card.name = card.name.gsub(/^#{Regexp.escape(root.card.name)}\+/, '+') if root.card.new_card?  ##FIXME -- need to match other relative inclusions.
      builder.new("card[cards][#{card.cardname.pre_cgi}]", card, template, {}, block)
    end
  
    def form
      @form ||= form_for_multi
    end

  end
end
