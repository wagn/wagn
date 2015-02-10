format :html do
  
  view :toggle, :perms=>:none, :closed=>true do |args|
    verb, adjective, direction = ( args[:toggle_mode] == :close ? %w{ open open e } : %w{ close closed s } )
    
    view_link '', adjective, :title => "#{verb} #{card.name}",
      :class => "#{verb}-icon ui-icon ui-icon-circle-triangle-#{direction} toggler slotter nodblclick"
  end
    

  view :header do |args|
    %{
      <h1 class="card-header">
        #{ _optional_render :toggle, args, :hide }
        #{ _optional_render :title, args }
        #{ _optional_render :menu, args }
      </h1>
    }
  end
  
  view :menu, :tags=>:unknown_ok, :perms=>:none, :closed=>true do |args|
    return _render_template_closer if args[:menu_hack] == :template_closer
    disc_tagname = Card.fetch(:discussion, :skip_modules=>true).cardname
    disc_card = unless card.new_card? or card.junction? && card.cardname.tag_name.key == disc_tagname.key
      Card.fetch "#{card.name}+#{disc_tagname}", :skip_virtual=>true, :skip_modules=>true, :new=>{}
    end

    @menu_vars = {
      :self         => card.name,
      :linkname     => card.cardname.url_key,
      :type         => card.type_name,
      :structure    => card.structure && card.template.ok?(:update) && card.template.name,
      :discuss      => disc_card && disc_card.ok?( disc_card.new_card? ? :comment : :read ),
      :piecenames   => card.junction? && card.cardname.piece_names[0..-2].map { |n| { :item=>n.to_s } },
      :related_sets => card.related_sets.map { |name,label| { :text=>label, :path_opts=>{ :current_set => name } } }
    }
    if card.real?
      @menu_vars.merge!({
        :edit      => card.ok?(:update),
        :account   => card.account && card.ok?(:update),
        :follow     => Auth.signed_in? && render_follow,
        :creator   => card.creator.name,
        :updater   => card.updater.name,
        :delete    => card.ok?(:delete) && link_to( 'delete', :action=>:delete,
          :class => 'slotter standard-delete', :remote => true, :'data-confirm' => "Are you sure you want to delete #{card.name}?"
        )
      })
    end

    json = html_escape_except_quotes JSON( @menu_vars )
    %{<span class="card-menu-link" data-menu-vars='#{json}'>#{_render_menu_link}</span>}
  end

  view :menu_link, :closed=>true, :perms=>:none do |args|
    '<a class="ui-icon ui-icon-gear"></a>'
  end
  
end
