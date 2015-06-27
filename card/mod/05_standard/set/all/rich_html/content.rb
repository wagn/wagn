def show_comment_box_in_related?
  false
end

format :html do

  def show view, args
    if show_layout?
      args.merge! :view=>view if view
      @main_opts = args
      self.render :layout
    else
      view ||= args[:home_view] || :open
      @inclusion_opts = args.delete(:items)
      render view, args
    end
  end

  def show_layout?
    !Env.ajax? || params[:layout]
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
        _optional_render( :menu, args ),
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
    title = fancy_title args[:title], args[:title_class]
    title =  _optional_render( :title_toolbar, args, (show_view?(:toolbar,args.merge(:default_visibility=>:hide)) || toolbar_pinned? ? :show : :hide)) ||
             _optional_render( :title_link, args.merge( :title_ready=>title ), :hide )       ||
             title
    #title += " (#{card.type_name})" if Card[:show_cardtype].content == 'true'
    add_name_context
    title
  end

  view :title_link do |args|
    card_link card.cardname, :text=>( args[:title_ready] || showname(args[:title]) )
  end

  view :title_toolbar do |args|
    links = card.cardname.parts.map do |name|
      card_link name
    end
    res = links.shift
    links.each_with_index do |link, index|
      res += card_link card.cardname.parts[0..index+1].join('+'), :text=>glyphicon('plus','header-icon')
      res += link
    end
    res += ' '
    res.concat view_link(glyphicon('edit','header-icon'),:edit_name, :class=>'slotter', 'data-toggle'=>'tooltip', :title=>'edit name')
    res
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
    frame args.reverse_merge(:content=>true, :body_class=>'closed-content', :toggle_mode=>:close, :optional_toggle=>:show, :optional_edit_toolbar=>:hide ) do
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

  def current_set_card
    set_name = params[:current_set]
    set_name ||= "#{card.name}+*type" if card.known? && card.type_id==Card::CardtypeID
    set_name ||= "#{card.name}+*self"
    Card.fetch(set_name)
  end


  view :related do |args|
    if rparams = args[:related] || params[:related]
      rcard = rparams[:card] || begin
                rcardname = rparams[:name].to_name.to_absolute_name( card.cardname)
                Card.fetch rcardname, :new=>{}
              end

      nest_args = ( rparams[:slot] || {} ).deep_symbolize_keys.reverse_merge(
        :view            => ( rparams[:view] || :open ),
        :optional_toggle => :hide,
        :optional_help   => :show,
        :optional_menu   => :show,
        :optional_close_related_link => :show,
        :parent          => card
      )
      nest_args[:optional_comment_box] = :show if rcard.show_comment_box_in_related?

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
    if act = card.last_act and action = act.action_on(card.id)
      action_verb =
        case action.action_type
        when :create then 'added'
        when :delete then 'deleted'
        else
          link_to('edited', path(:view=>:history), :class=>'last-edited', :rel=>'nofollow')
        end

      %{
        <span class="last-update">
          #{ action_verb }
          #{ _render_acted_at }
          ago by
          #{ subformat(card.last_actor)._render_link }
        </span>
      }
    end
  end

  private

  def fancy_title title=nil, title_class=nil
    raw %{<span class="card-title#{" #{title_class}"if title_class}">#{ showname(title).to_name.parts.join %{<span class="joint">+</span>} }</span>}
  end
end


