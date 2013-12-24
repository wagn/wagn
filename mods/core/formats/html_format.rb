# -*- encoding : utf-8 -*-

require_dependency 'card/diff'

class Card::HtmlFormat < Card::Format
  include Card::Diff
  
  attr_accessor  :options_need_save, :start_time, :skip_autosave

  # builtin layouts allow for rescue / testing
  LAYOUTS = Wagn::Loader.load_layouts.merge 'none' => '{{_main}}'

  INCLUSION_DEFAULTS = {
    :layout => { :view => :core },
    :normal => { :view => :content }
  }
  
  
  def get_inclusion_defaults
    INCLUSION_DEFAULTS[@mode] || {}
  end
  
  def default_item_view
    :closed
  end

  def view_for_unknown view, args
    case
    when focal? && ok?( :create )   ;  :new
    when commentable?( view, args ) ;  view
    else                               super
    end
  end

  def commentable? view, args
    self.class.tagged view, :comment and 
    args[:show] =~ /comment_box/     and
    ok? :comment
  end

  def get_layout_content(args)
    Account.as_bot do
      case
        when (params[:layout] || args[:layout]) ;  layout_from_name args
        when card                               ;  layout_from_card
        else                                    ;  LAYOUTS['default']
      end
    end
  end

  def layout_from_name args
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
    #return unless rule_card.is_a?(Card::Set::Type::Pointer) and  # type check throwing lots of warnings under cucumber: rule_card.type_id == Card::PointerID        and
    return unless rule_card.type_id == Card::PointerID        and
        layout_name=rule_card.item_names.first                and
        !layout_name.nil?                                     and
        lo_card = Card.fetch( layout_name, :skip_virtual => true, :skip_modules=>true ) and
        lo_card.ok?(:read)
    lo_card.content
  end

  def slot_options args
    @@slot_option_keys ||= Card::Chunk::Include.options.reject { |k| k == :view }.unshift :home_view
    options_hash = {}
    
    if @context_names.present?
      options_hash['name_context'] = @context_names.map( &:key ) * ','
    end
    
    @@slot_option_keys.inject(options_hash) do |hash, opt|
      hash[opt] = args[opt] if args[opt].present?
      hash
    end
    
    JSON( options_hash )
  end

  def wrap view, args = {}
    classes = [
      ( 'card-slot' unless args[:no_slot] ),
      "#{view}-view",
      ( args[:slot_class] if args[:slot_class] ),
      ( "STRUCTURE-#{args[:structure].to_name.key}" if args[:structure]),
      card.safe_set_keys
    ].compact
    
    div = %{<div id="#{card.cardname.url_key}" data-card-id="#{card.id}" data-card-name="#{h card.name}" style="#{h args[:style]}" class="#{classes*' '}" } +
      %{data-slot='#{html_escape_except_quotes slot_options( args )}'>#{yield}</div>}

    if args[:no_wrap_comment]
      div
    else
      name = h card.name
      space = '  ' * @depth
      %{<!--\n\n#{ space }BEGIN SLOT: #{ name }\n\n-->#{ div }<!--\n\n#{space}END SLOT: #{ name }\n\n-->}
    end
  end
  
  def wrap_body args={}
    css_classes = [ 'card-body' ]
    css_classes << args[:body_class]                  if args[:body_class]
    css_classes += [ 'card-content', card.safe_set_keys ] if args[:content]
    content_tag :div, :class=>css_classes.compact*' ' do
      yield args
    end
  end
    
  def wrap_frame view, args={}
    wrap view, args.merge(:slot_class=>'card-frame') do
      %{
        #{ _render_header args }
        #{ %{ <div class="card-subheader">#{ args[:subheader] }</div> } if args[:subheader] }
        #{ _render_help args if args[:show_help] }
        #{ wrap_body args do yield args end }
      }
    end
  end

  def wrap_main(content)
    return content if params[:layout]=='none'
    %{#{
    if flash[:notice]
      %{<div class="flash-notice">#{ flash[:notice] }</div>}
    end
    }<div id="main">#{content}</div>}
  end

  
  def html_escape_except_quotes s
    # to be used inside single quotes (makes for readable json attributes)
    s.to_s.gsub(/&/, "&amp;").gsub(/\'/, "&apos;").gsub(/>/, "&gt;").gsub(/</, "&lt;")
  end


  def edit_slot args={}
    if card.structure
      _render_raw(args).scan( /\{\{\s*\+[^\}]*\}\}/ ).map do |inc|
        process_content( inc ).strip
      end.join
#        raw _render_core(args)
    elsif label = args[:label]
      label = '' if label == true
      fieldset label, content_field( form, args ), :editor=>:content
    else
      editor_wrap( :content ) { content_field form, args }
    end
  end
  

  #### --------------------  additional helpers ---------------- ###

  def rendering_error exception, view
    %{
      <span class="render-error">
        error rendering
        #{
          if Account.always_ok?
            %{
              #{ link_to_page error_cardname, nil, :class=>'render-error-link' }
              <div class="render-error-message errors-view" style="display:none">
                <h3>Error message (visible to admin only)</h3>
                <p><strong>#{ exception.message }</strong></p>
                <div>
                  #{exception.backtrace * "<br>\n"}
                </div>
              </div>
            }
          else
            error_cardname
          end
        }
        (#{view} view)
      </span>
    }
  end
  
  def unknown_view view
    "<strong>unknown view: <em>#{view}</em></strong>"
  end
  
  def unsupported_view view
    "<strong>view <em>#{view}</em> not supported for <em>#{error_cardname}</em></strong>"
  end

  def final_link href, opts={}
    text = opts[:text] || href
    %{<a class="#{opts[:class]}" href="#{href}">#{text}</a>}
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
    unless args[:no_current_type] || card.new_card? || typelist.include?( card.type_name )
      # current type should be an option on existing cards, regardless of create perms
      typelist = (typelist + card.type_name).sort
    end
    current_type = args[:no_current_type] ? nil : Card[ card ? card.type_id : Card.default_type_id ].name

    options = options_from_collection_for_select typelist, :to_s, :to_s, current_type
    template.select_tag 'card[type]', options, args
  end

  def content_field form, options={}
    @form = form
    @nested = options[:nested]
    revision_tracking = if card && !card.new_card? && !options[:skip_rev_id]
      form.hidden_field :current_revision_id, :class=>'current_revision_id'
    end
    %{
      #{ revision_tracking }
      #{ _render_editor options }
    }
  end

  def form_for_multi
    block = Proc.new {}
    builder = ActionView::Base.default_form_builder
    card.name = card.name.gsub(/^#{Regexp.escape(root.card.name)}\+/, '+') if root.card.new_card?  ##FIXME -- need to match other relative inclusions.
    
    builder.new("card[cards][#{card.relative_name}]", card, template, {}, block)
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
    opts[:html][:recaptcha] = 'on' if Wagn::Env[:recaptcha_on] && Card.toggle( card.rule(:captcha) )
    opts
  end

  def editor_wrap type=nil
    content_tag( :div, :class=>"editor#{ " #{type}-editor" if type }" ) { yield }
  end

  def fieldset title, content, opts={}
    if attribs = opts[:attribs]
      attrib_string = attribs.keys.map do |key| 
        %{#{key}="#{attribs[key]}"}
      end * ' '
    end
    help_text = case opts[:help]
      when String ; _render_help :help_text=> opts[:help]
      when true   ; _render_help
      else        ; nil
    end
    %{
      <fieldset #{ attrib_string }>
        <legend>
          <h2>#{ title }</h2>
          #{ help_text }
        </legend>
        #{ editor_wrap( opts[:editor] ) { content } }
      </fieldset>
    }
  end
  
  def hidden_tags hash, base=nil
    # convert hash into a collection of hidden tags
    result = ''
    hash.each do |key, val|
      result += if Hash === val
        hidden_tags val, key
      else
        name = base ? "#{base}[#{key}]" : key
        hidden_field_tag name, val
      end
    end
    result
  end

  def main?
    if ajax_call?
      @depth == 0 && params[:is_main]
    else
      @depth == 1 && @mainline
    end
  end

  private

  def fancy_title title=nil
    raw %{<span class="card-title">#{ showname(title).to_name.parts.join %{<span class="joint">+</span>} }</span>}
  end

end
