format :html do

  view :header do |args|
    %{
      <div class="card-header #{ args[:header_class] }">
        <div class="card-header-title #{ args[:title_class] }">
          #{ _optional_render :toggle, args, :hide }
          #{ _optional_render :title, args }
        </div>
        #{ _optional_render :menu, args }
      </div>
    }
  end

  view :toggle do |args|
    verb, adjective, direction = ( args[:toggle_mode] == :close ? %w{ open open expand } : %w{ close closed collapse-down } )
  
    link_to  glyphicon(direction), #content_tag(:span, '', :class=>"glyphicon glyphicon-#{direction}"),
             path( :view=>adjective ),
             :remote => true,
             :title => "#{verb} #{card.name}",
             :class => "#{verb}-icon toggler slotter nodblclick"
  end

  
  view :menu, :tags=>:unknown_ok do |args|
    return _render_template_closer if args[:menu_hack] == :template_closer
    disc_tagname = Card.fetch(:discussion, :skip_modules=>true).cardname
    disc_card = unless card.new_card? or card.junction? && card.cardname.tag_name.key == disc_tagname.key
      Card.fetch "#{card.name}+#{disc_tagname}", :skip_virtual=>true, :skip_modules=>true, :new=>{}
    end

    @menu_vars = {
      :self          => card.name,
      :linkname      => card.cardname.url_key,
      :type          => card.type_name,
      :structure     => card.structure && card.template.ok?(:update) && card.template.name,
      :discuss       => disc_card && disc_card.ok?( disc_card.new_card? ? :comment : :read ),
      :piecenames    => card.junction? && card.cardname.piece_names[0..-2].map { |n| { :item=>n.to_s } },
      :related_sets  => card.related_sets.map { |name,label| { :text=>label, :path_opts=>{ :current_set => name } } }
    }
    if card.real?
      @menu_vars.merge!({
        :edit      => card.ok?(:update),
        :account   => card.account && card.ok?(:update),
        :show_follow    => show_follow?,
        :follow_menu    => show_follow? && render_follow_link(:label=>''),
        :follow_submenu => show_follow? && render_follow_link,
        :creator   => card.creator.name,
        :updater   => card.updater.name,
        :delete    => card.ok?(:delete) && link_to( 'delete', :action=>:delete,
        :class     => 'slotter standard-delete', :remote => true, :'data-confirm' => "Are you sure you want to delete #{card.name}?"
        )
      })
    end

    json = html_escape_except_quotes JSON( @menu_vars )
    %{<span class="card-menu-link" data-menu-vars='#{json}'>#{_render_menu_link}</span>}
  end

  view :menu_link do |args|
    glyphicon 'cog'
  end

  view :link_list do |args|
    content_tag :ul, :class=>args[:class] do
      item_links(args).map do |al|
        content_tag :li, raw(al)
      end.join "\n"
    end
  end
  
  view :navbar_right do |args|
    render_link_list args.merge(:class=>"nav navbar-nav navbar-right")
  end
  
  view :navbar_left do |args|
    render_link_list args.merge(:class=>"nav navbar-nav navbar-left")
  end
  
  def show_follow?
    Auth.signed_in? && !card.new_card?
  end
  
  
end

