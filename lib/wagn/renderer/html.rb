module Wagn
  class Renderer::Html < Renderer

    attr_accessor  :options_need_save, :start_time, :skip_autosave
    DEFAULT_ITEM_VIEW = :closed

    # these initialize the content of missing builtin layouts
    LAYOUTS = { 'default' => %{
  <!DOCTYPE HTML>
  <html>
    <head> {{*head}} </head>

    <body id="wagn">
      <div id="menu">
        [[/ | Home]]   [[/recent | Recent]]   {{*navbox}} {{*account links}}
      </div>

      <div id="primary"> {{_main}} </div>

      <div id="secondary">
        <div id="logo">[[/ | {{*logo}}]]</div>
        {{*sidebar}}
        <div id="credit"><a href="http://www.wagn.org" title="Wagn {{*version}}">Wagn.</a> We're on it.</div>
        {{*alerts}}
      </div>

    </body>
  </html> },

          'blank' => %{
  <!DOCTYPE HTML>
  <html>
    <head> {{*head}} </head>
    <body id="wagn"> {{_main}} </body>
  </html> },

          'simple' => %{
  <!DOCTYPE HTML>
  <html>
    <head> {{*head}} </head>
    <body> {{_main}} </body>
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

    </body>
  </html> },

          'pre' => %{
  <!DOCTYPE HTML>
  <html> <body><pre>{{_main|raw}}</pre></body> </html> },

   }


    def get_layout_content(args)
      Session.as_bot do
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
      return unless rule_card = (card.rule_card(:layout) or Card.default_rule_card(:layout))
      #return unless rule_card.is_a?(Wagn::Set::Type::Pointer) and  # type check throwing lots of warnings under cucumber: rule_card.type_id == Card::PointerID        and
      return unless rule_card.type_id == Card::PointerID        and
          layout_name=rule_card.item_names.first                and
          !layout_name.nil?                                     and
          lo_card = Card.fetch( layout_name, :skip_virtual => true, :skip_modules=>true ) and
          lo_card.ok?(:read)
      lo_card.content
    end


    def wrap view, args = {}
      classes = ['card-slot', "#{view}-view"]
      classes << card.safe_keys if card
    
      attributes = { :class => classes.join(' ') }
      [:style, :home_view, :item].each { |key| attributes[key] = args[key] }
      
      if card
        attributes['card-id']  = card.id
        attributes['card-name'] = card.name
      end
    
      content_tag(:div, attributes ) { yield }
    end

    def wrap_content( view, content="" )
      raw %{<span class="#{view}-content content">#{content}</span>}
    end

    def wrap_main(content)
      return content if params[:layout]=='none'
      %{#{
      if flash[:notice]
        %{<div class="flash-notice">#{ flash[:notice] }</div>}
      end
      }<div id="main">#{content}</div>}
    end

    def edit_slot args={}
      if card.hard_template
        _render_raw.scan( /{{[^}]*}}/ ).map do |inc|
          process_content( inc ).strip
        end.join
#        raw _render_core(args)
      elsif card.new_card?
        fieldset 'content', content_field( form )
      else
        content_field form
      end
    end
 
    #### --------------------  additional helpers ---------------- ###
    def notice
      %{<div class="card-notice"></div>}
    end

    def wrap_submenu
      %{<div class="submenu">
          <span class="submenu-left card-report"></span>
          <span class="submenu-right">#{yield}</span>
        </div> }
    end

    def rendering_error exception, cardname
      %{<span class="render-error">error rendering #{link_to_page(cardname, nil, :title=>CGI.escapeHTML(exception.message))}</span>}
    end

    def edit_submenu(current)
      wrap_submenu do
        [ :content, :name, :type ].map do |attr|
          next if attr == :type and # this should be a set callback
            card.type_template? ||  
            (card.type_id==Card::SetID && card.hard_template?) || #
            (card.type_id==Card::CardtypeID && card.cards_of_type_exist?)
        
          link_to attr, path(:edit, :attrib=>attr), :remote=>true,
            :class => %{slotter edit-#{ attr }-link #{'current-subtab' if attr==current.to_sym}}
        end.compact * "\n"
      end
    end

    def options_submenu(current)
      return '' unless !card || [Card::WagnBotID, Card::AnonID].member?(card.id) || card.type_id == Card::UserID
      wrap_submenu do
        [:account, :settings].map do |key|
          link_to key, path(:options, :attrib=>key), :remote=>true,
            :class=> %{slotter#{' current-subtab' if key==current}}
        end * "\n"
      end
    end

    def menu
      menu_options = if card && card.virtual?
        [:view,:options,:virtual]
      else
        [:view,:changes,:options,:related,:edit]
      end
      top_option = menu_options.pop
      menu = %{<span class="card-menu">\n}
        menu << %{<span class="card-menu-left">\n}
          menu_options.each do |opt|
            menu << link_to_menu_action(opt)
          end
        menu << "</span>"
        menu << if top_option == :virtual
          %{<li class="virtual-edit">Virtual</li>\n}
        else
          link_to_menu_action(top_option)
        end
      menu << "</span>"
      menu.html_safe
      menu
    end



    def link_to_menu_action( to_action)
      klass = { :edit => 'edit-content-link'}
      content_tag :li, link_to_action( to_action.to_s.capitalize, to_action,
        :class=> "slotter #{klass[to_action]}" #{}" #{menu_action==to_action ? ' current' : ''}"
      )
    end

    def link_to_action text, to_action, html_opts={}
      html_opts[:remote] = true
      path_options = to_action == :view ? {} : { :view => to_action}
      link_to text, path(:read, path_options), html_opts
    end

    def name_field form, options={}
      form.text_field( :name, { 
        :value=>card.name, #needed because otherwise gets wrong value if there are updates
        :autocomplete=>'off'
      }.merge(options))
    end

    def type_field args={}
      typelist = Session.createable_types
      typelist << card.type_name if !card.new_card?
      # current type should be an option on existing cards, regardless of create perms

      options = options_from_collection_for_select(
        typelist.uniq.sort.map { |name| [ name, name ] },
        :first, :last, Card[ card ? card.type_id : Card::DefaultTypeID ].name )
      template.select_tag 'card[type]', options, args
    end

    def content_field form, options={}
      @form = form
      @nested = options[:nested]
      revision_tracking = if card && !card.new_card? && !options[:skip_rev_id]
        form.hidden_field :current_revision_id, :class=>'current_revision_id'
      end
      editor_wrap :content do
        %{
        #{ revision_tracking }
        #{ _render_editor    }
        }
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

    def option content, args
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
      %{<tr><th colspan="3" class="option-header"><h2>#{title}</h2></th></tr>}
    end
    
    # navigation for revisions -
    # --------------------------------------------------
    # some of this should be in rich_html, maybe most
    def revision_link text, revision, name, accesskey='', mode=nil
      link_to text, path(:changes, :rev=>revision, :mode=>(mode || params[:mode] || true) ), 
        :class=>"slotter", :remote=>true
    end

    def rollback to_rev=nil
      to_rev ||= @revision_number
      if card.ok?(:update) && !(card.current_revision==@revision)
        link_to 'Save as current', path(:rollback, :rev=>to_rev),
          :class=>'slotter', :remote=>true
      end
    end

    def revision_menu
      revision_menu_items.flatten.map do |item|
        "<span>#{item}</span>"
      end.join('')
    end

    def revision_menu_items
      items = [back_for_revision, forward, see_or_hide_changes_for_revision]
      items << rollback unless Wagn::Conf[:recaptcha_on]
      items
    end

    def forward
      if @revision_number < card.revisions.length
        revision_link('Newer', @revision_number +1, 'to_next_revision', 'F' ) +
          raw(" <small>(#{card.revisions.length - @revision_number})</small>")
      else
        'Newer <small>(0)</small>'
      end
    end

    def back_for_revision
      if @revision_number > 1
        revision_link('Older',@revision_number - 1, 'to_previous_revision') +
          raw("<small>(#{@revision_number - 1})</small>")
      else
        'Older <small>(0)</small>'
      end
    end

    def see_or_hide_changes_for_revision
      revision_link(@show_diff ? 'Hide changes' : 'Show changes',
        @revision_number, 'see_changes', 'C', (@show_diff ? 'false' : 'true'))
    end

    def autosave_revision
       revision_link("Autosaved Draft", card.revisions.count, 'to autosave')
    end
  end
  
end
