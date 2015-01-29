format :html do
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
  
  
  def wrap args = {}
    classes = [
      ( 'card-slot' unless args[:no_slot] ),
      "#{ @current_view }-view",
      ( args[:slot_class] if args[:slot_class] ),
      ( "STRUCTURE-#{args[:structure].to_name.key}" if args[:structure]),
      card.safe_set_keys
    ].compact
  
    div = %{<div id="#{card.cardname.url_key}" data-card-id="#{card.id}" data-card-name="#{h card.name}" data-card-type-code="#{card.type_code}" style="#{h args[:style]}" class="#{classes*' '}" } +
      %{data-slot='#{html_escape_except_quotes slot_options( args )}'>#{ output yield }</div>}

    if params[:debug] == 'slot' && !tagged( @current_view, :no_wrap_comments )
      name = h card.name
      space = '  ' * @depth
      %{<!--\n\n#{ space }BEGIN SLOT: #{ name }\n\n-->#{ div }<!--\n\n#{space}END SLOT: #{ name }\n\n-->}
    else
      div
    end
  end

  def wrap_body args={}
    css_classes = [ 'card-body' ]
    css_classes << args[:body_class]                      if args[:body_class]
    css_classes += [ 'card-content', card.safe_set_keys ] if args[:content]
    content_tag :div, :class=>css_classes.compact*' ' do
      yield args
    end
  end
  
  def frame args={}
    wrap args.merge(:slot_class=>'card-frame') do
      %{
        #{ _render_header args }
        #{ %{ <div class="card-subheader">#{ args[:subheader] }</div> } if args[:subheader] }
        #{ _optional_render :help, args, :hide }
        #{ wrap_body args do output( yield args ) end }
      }
    end
  end

  def frame_and_form action, args={}, form_opts={}
    form_opts.merge! args.delete(:form_opts) if args[:form_opts]
    form_opts[:hidden] = args.delete(:hidden)
    frame args do
      card_form action, form_opts do
        output( yield args )
      end
    end
  end
  
  def wrap_main(content)
    return content if params[:layout]=='none'
    %{<div id="main">#{content}</div>}
  end
end