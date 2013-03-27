module Wagn
  class Renderer::Html < Renderer
    cattr_accessor :default_menu
    attr_accessor  :options_need_save, :start_time, :skip_autosave
#    DEFAULT_ITEM_VIEW = :closed  #FIXME: It can't access this default

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
   
   
    @@default_menu ||= [ 
      { :view=>:edit, :text=>'edit', :if=>:edit, :sub=>[
          { :view=>:edit,      :text=>'content'       },
          { :view=>:edit_name, :text=>'name'          },
          { :view=>:edit_type, :text=>'type: %{type}' },
          { :related=>{ :name=>:structure, :view=>:edit }, :text=>'structure', :if=>:structure },
        ] },
      { :view=>:home, :text=>'view', :sub=> [
          { :view=>:home,                    :text=>'refresh'                    },
          { :page=>:self,                    :text=>'page'                       },
          { :page=>:type,                    :text=>'type: %{type}'              },
          { :view=>:changes,                 :text=>'history',   :if=>:edit      },
          { :related=>{ :name=>:structure }, :text=>'structure', :if=>:structure },
        ] },
      { :related=>{ :name=>"+discussion" }, :text=>'discuss', :if=>:discuss },
      { :view=>:options, :text=>'advanced', :sub=>[
          { :view=>:options, :text=>'rules' },
          { :related=>"+*referred to by",     :text=>"references to", :sub=>[
              { :related=>"+*referred to by", :text=>"all"        },                  
              { :related=>"+*linkers",        :text=>"links"      },                  
              { :related=>"+*includers",      :text=>"inclusions" }
            ] },            
          { :related=>"+*refers to",          :text=>"references from", :sub=>[
              { :related=>"+*refers to",      :text=>"all"        },
              { :related=>"+*links",          :text=>"links"      },
              { :related=>"+*inclusions",     :text=>"inclusions" }                  
            ] },
          { :plain=>'related', :sub=>[
              { :plain=>'ancestors', :if=>:piecenames, :sub=>{ :piecenames => { :page=>:item } } },
              { :related=>"+*plus cards", :text=>'children' },
              { :related=>"+*plus parts", :text=>'mates'    },
            ] },              
          { :related=>'+*editors', :text=>'editors', :if=>:creator, :sub=>[
              { :related=>"+*editors", :text=>'all editors'             },
              { :page=>:creator,       :text=>"creator: %{creator}"     },
              { :page=>:updater,       :text=>"last editor: %{updater}" },
            ] },
        ] },
        { :link=>:watch,   :if=>:watch   },
        { :view=>:account, :if=>:account, :sub=>[
            { :view=>:account,       :text=>'details' },
            { :related=>"+*created", :text=>'created' },
            { :related=>"+*editing", :text=>'edited'  }
          ] }

    ]

=begin
, :sub=>[
    { :view=>:titled  },
    { :view=>:open    },
    { :view=>:closed  },
    { :view=>:content },
#              { :view=>:change  },  
  ]
=end


    def get_layout_content(args)
      Account.as_bot do
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
      classes << 'card-frame' if args[:frame]
      classes << card.safe_keys if card

      attributes = { 
        :class => classes*' ',
        :style=>args[:style]
      }
      
      [:home_view, :item, :include, :show, :hide, :size].each do |key|
        attributes["slot-#{key}"] = args[key] if args[key].present?
      end

      if card
        attributes['card-id']  = card.id
        attributes['card-name'] = card.name
      end
      
      if @context_names
        attributes['slot-name_context'] = @context_names.map( &:key ) * ','
      end
      
      content_tag(:div, attributes ) { yield }
    end

    def wrap_content view, args={}
      raw %{<span class="#{view}-content content #{'card-body' if args[:body] } #{args[:class]}">#{ yield }</span>}
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
        _render_raw.scan( /\{\{[^\}]*\}\}/ ).map do |inc|
          process_content( inc ).strip
        end.join
#        raw _render_core(args)
#      elsif card.new_card?
#        fieldset '', content_field( form )
      else
        content_field form
      end
    end

    #### --------------------  additional helpers ---------------- ###
    def notice
      %{<div class="card-notice"></div>}
    end

    def rendering_error exception, view
      %{<span class="render-error">error rendering #{link_to_page(error_cardname, nil, :title=>CGI.escapeHTML(exception.message))} (#{view} view)</span>}
    end
    
    def unknown_view view
      "<strong>unknown view: <em>#{view}</em></strong>"
    end
    
    def unsupported_view view
      "<strong>view <em>#{view}</em> not supported for <em>#{error_cardname}</em></strong>"
    end

    def link_to_view text, view, opts={}
      path_opts = view==:home ? {} : { :view=>view }
      if p = opts.delete( :path_opts )
        path_opts.merge! p
      end
      opts[:remote] = true
      opts[:rel] = 'nofollow'
      link_to text, path( path_opts ), opts
    end

    def name_field form=nil, options={}
      form ||= self.form
      form.text_field( :name, {
        :value=>card.name, #needed because otherwise gets wrong value if there are updates
        :autocomplete=>'off'
      }.merge(options))
    end

    def type_field args={}
      typelist = Account.createable_types
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
        #{ _render_editor options }
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

    def card_form *opts
      form_for( card, form_opts(*opts) ) { |form| yield form }
    end

    def form_opts url, classes='', other_html={}
      url = path(:action=>url) if Symbol===url
      opts = { :url=>url, :remote=>true, :html=>other_html }
      opts[:html][:class] = classes + ' slotter'
      opts[:html][:recaptcha] = 'on' if Wagn::Conf[:recaptcha_on] && Card.toggle( card.rule(:captcha) )
      opts
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

    def option_header title
      raw %{<tr><th colspan="3" class="option-header"><h2>#{title}</h2></th></tr>}
    end

    def editor_wrap type
      content_tag( :div, :class=>"editor #{type}-editor" ) { yield }
    end

    def fieldset title, content, opts={}
      if attribs = opts[:attribs]
        attrib_string = attribs.keys.map do |key| 
          %{#{key}="#{attribs[key]}"}
        end * ' '
      end
      %{
        <fieldset #{ attrib_string }>
          <legend>
            <h2>#{ title }</h2>
            #{ help_text *opts[:help] }
          </legend>
          #{ content }
        </fieldset>
      }
    end

    def main?
      if ajax_call?
        @depth == 0 && params[:is_main]
      else
        @depth == 1 && @mainline
      end
    end

    private

    def help_text *opts
      text = case opts[0]
        when Symbol
          if help_card = card.rule_card( *opts )
            with_inclusion_mode :normal do
              subrenderer( help_card ).render_core
            end
          end
        when String
          opts[0]
        end
      %{<div class="instruction">#{raw text}</div>} if text
    end

    def fancy_title name=nil
      name ||= showname
      title = name.to_name.parts.join %{<span class="joint">+</span>}
      raw title
    end

    def load_revisions
      @revision_number = (params[:rev] || (card.revisions.count - card.drafts.length)).to_i
      @revision = card.revisions[@revision_number - 1]
      @previous_revision = @revision ? card.previous_revision( @revision.id ) : nil
      @show_diff = (params[:mode] != 'false')
    end


    # navigation for revisions -
    # --------------------------------------------------
    # some of this should be in rich_html, maybe most
    def revision_link text, revision, name, accesskey='', mode=nil
      link_to text, path(:view=>:changes, :rev=>revision, :mode=>(mode || params[:mode] || true) ),
        :class=>"slotter", :remote=>true, :rel=>'nofollow'
    end

    def rollback to_rev=nil
      to_rev ||= @revision_number
      if card.ok?(:update) && !(card.current_revision==@revision)
        link_to 'Save as current', path(:action=>:rollback, :rev=>to_rev),
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
      if @revision_number < card.revisions.count
        revision_link('Newer', @revision_number +1, 'to_next_revision', 'F' ) +
          raw(" <small>(#{card.revisions.count - @revision_number})</small>")
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
