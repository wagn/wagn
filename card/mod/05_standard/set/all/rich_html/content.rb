
format :html do

  def show view, args
    if Env.ajax?
      view ||= args[:home_view] || :open
      @inclusion_opts = args.delete(:items)
      render view, args
    else
      args.merge! :view=>view if view
      @main_opts = args
      self.render :layout
    end
  end

  view :layout, :perms=>:none do |args|
    process_content get_layout_content, :content_opts=>{ :chunk_list=>:references }
  end

  view :content do |args|
    wrap args.reverse_merge(:slot_class=>'card-content') do
      [
        _optional_render( :menu, args, :hide ),
        _render_core( args )
      ]
    end
  end
  
  view :content_panel do |args|
    wrap args.reverse_merge(:slot_class=>'card-content panel panel-default') do
      wrap_with :div, :class=>'panel-body' do
        [
          _optional_render( :menu, args, :hide ),
          _render_core( args )
          ]*"\n"
      end
    end
  end

  view :titled, :tags=>:comment do |args|
    wrap args do   
      [
        _render_header( args ),
        wrap_body( :content=>true ) { _render_core args },
        optional_render( :comment_box, args )
      ]
    end
  end

  view :labeled do |args|
    wrap args do
      [
        _optional_render( :menu, args ),
        "<label>#{ _render_title args }</label>",
        wrap_body( :body_class=>'closed-content', :content=>true ) do
          _render_closed_content args
        end
      ]
    end
  end

  view :title do |args|
    title = fancy_title args[:title]
    title = _optional_render( :title_link, args.merge( :title_ready=>title ), :hide ) || title
    add_name_context
    title
  end

  view :title_link do |args|
    card_link card.cardname, :text=>( args[:title_ready] || showname(args[:title]) )
  end

  view :open, :tags=>:comment do |args|
    args[:optional_toggle] ||= main? ? :hide : :show
    frame args.merge(:content=>true) do
      [
        _render_open_content( args ),
        optional_render( :comment_box, args )
      ]
    end
  end

  
  
=begin  
  view :anchor, :perms=>:none, :tags=>:unknown_ok do |args|
    %{ <a id="#{card.cardname.url_key}" name="#{card.cardname.url_key}"></a> }
  end
=end  

  view :type do |args|
    klasses = ['cardtype']
    klass = args[:type_class] and klasses << klass
    card_link card.type_card.name, :class=>klasses
  end

  view :closed do |args|
    frame args.reverse_merge(:content=>true, :body_class=>'closed-content', :toggle_mode=>:close, :optional_toggle=>:show ) do
      _optional_render :closed_content, args
    end
  end


  view :change do |args|
    args[:optional_title_link] = :show
    wrap args do
      [
        _optional_render( :title, args       ),
        _optional_render( :menu, args, :hide ),
        _optional_render( :last_action, args )
      ]
    end
  end

  view :options, :tags=>:unknown_ok do |args|
    current_set = Card.fetch( params[:current_set] || card.related_sets[0][0] )

    frame args do
      subformat( current_set ).render_content
    end
  end


  view :related do |args|
    if rparams = params[:related]
      rcardname = rparams[:name].to_name.to_absolute_name( card.cardname)
      rcard = Card.fetch rcardname, :new=>{}

      nest_args = {
        :view          => ( rparams[:view] || :open ),
        :optional_toggle => :hide,
        :optional_help => :show,
        :optional_menu => :show
      }
      
      nest_args[:optional_comment_box] = :show if rparams[:name] == '+discussion' #fixme.  yuck!

      frame args do
        nest rcard, nest_args
      end
    end
  end
  
  view :help, :tags=>:unknown_ok do |args|
    text = if args[:help_text]
      args[:help_text]
    else
      setting = card.new_card? ? [ :add_help, { :fallback => :help } ] : :help
      if help_card = card.rule_card( *setting ) and help_card.ok? :read
        with_inclusion_mode :normal do
          process_content _render_raw( args.merge :structure=>help_card.name ), :content_opts=>{ :chunk_list=>:references }
          # render help card with current card's format so current card's context is used in help card inclusions
        end
      end
    end
    klass = [args[:help_class], 'help-text'].compact*' '
    %{<div class="#{klass}">#{raw text}</div>} if text
  end

  
  view :last_action do |args|
    action_type = case ( action = card.last_act.action_on(card.id) and action.action_type )
    when :create then 'added'
    when :delete then 'deleted'
    else
      link_to('edited', path(:view=>:history), :class=>'last-edited', :rel=>'nofollow')
    end
    %{
      <span class="last-update">
        #{ action_type }
        #{ _render_acted_at }
        ago by
        #{ subformat(card.last_actor)._render_link }
      </span> 
    }
  end

  private

  def fancy_title title=nil
    raw %{<span class="card-title">#{ showname(title).to_name.parts.join %{<span class="joint">+</span>} }</span>}
  end
end


