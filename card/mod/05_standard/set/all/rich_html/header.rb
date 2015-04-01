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
      #{ _optional_render :toolbar, args, :hide}
      #{ _optional_render :edit_toolbar, args, :hide}
      #{ _optional_render :account_toolbar, args, :hide}
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
    # disc_tagname = Card.fetch(:discussion, :skip_modules=>true).cardname
    # disc_card = unless card.new_card? or card.junction? && card.cardname.tag_name.key == disc_tagname.key
    #   Card.fetch "#{card.name}+#{disc_tagname}", :skip_virtual=>true, :skip_modules=>true, :new=>{}
    # end
    #
    # @menu_vars = {
    #   :self          => card.name,
    #   :linkname      => card.cardname.url_key,
    #   :type          => card.type_name,
    #   :structure     => card.structure && card.template.ok?(:update) && card.template.name,
    #   :discuss       => disc_card && disc_card.ok?( disc_card.new_card? ? :comment : :read ),
    #   :piecenames    => card.junction? && card.cardname.piece_names[0..-2].map { |n| { :item=>n.to_s } },
    #   :related_sets  => card.related_sets.map { |name,label| { :text=>label, :path_opts=>{ :current_set => name } } }
    # }
    # if card.real?
    #   @menu_vars.merge!({
    #     :edit      => card.ok?(:update),
    #     :account   => card.account && card.ok?(:update),
    #     :show_follow    => show_follow?,
    #     :follow_menu    => show_follow? && render_follow_link(:label=>''),
    #     :follow_submenu => show_follow? && render_follow_link,
    #     :creator   => card.creator.name,
    #     :updater   => card.updater.name,
    #     :delete    => card.ok?(:delete) && link_to( 'delete', :action=>:delete,
    #                     :class => 'slotter standard-delete',
    #                     :remote => true,
    #                     :'data-confirm' => "Are you sure you want to delete #{card.name}?"
    #                   )
    #   })
    # end
    #
    # json = html_escape_except_quotes JSON( @menu_vars )
    #%{<span class="card-menu-link" data-menu-vars='#{json}'>#{_render_menu_link}</span>}
    _optional_render(:horizontal_menu, args,:hide) || _render_menu_link(args)
    #_render_menu_link(args)
  end

  view :vertical_menu, :tags=>:unknown_ok do |args|
    content_tag :div, :class=>'btn-group slotter pull-right card-menu' do
      %{
        <span class="open-menu dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
          <a href='#'>#{ glyphicon 'cog'}</a>
        </span>
        <ul class="dropdown-menu" role="menu">
          #{_render_menu_item_list(args)}
        </ul>
        #{nest( card.fetch(:trait=>:follow_dialog), :view=>:modal) if args[:show_menu_item][:follow]}
      }.html_safe
    end
  end

  view :horizontal_menu do |args|
    content_tag :ul, :class=>'btn-group slotter pull-right card-menu horizontal-card-menu' do
      _render_menu_item_list(args.merge(:item_class=>'btn btn-default')).html_safe
    end.concat "#{nest( card.fetch(:trait=>:follow_dialog), :view=>:modal) if args[:show_menu_item][:follow]}".html_safe
  end


  view :menu_link do |args|
    path_opts = {:slot => {:home_view=>args[:home_view]}}
    path_opts[:is_main] = true if main?
    content_tag :div, :class=>'btn-group pull-right slotter card-slot card-menu ' do
      view_link(glyphicon('cog'), :vertical_menu, :path_opts=>path_opts).html_safe
    end
  end


  view :menu_item_list do |args|
    disc_tagname = Card.fetch(:discussion, :skip_modules=>true).cardname
    home_view = args[:home_view] || :open
    menu_items = []
    menu_items << menu_item('edit', 'edit', :view=>:edit,
                                            :path_opts=>{:slot=>{:show=>'toolbar structure_link',
                                                                 :hide=>'type_link'}})   if args[:show_menu_item][:edit]
    menu_items << menu_item('discuss', 'comment', :related=>disc_tagname)                if args[:show_menu_item][:discuss]
    menu_items << render_follow_menu_link                                                if args[:show_menu_item][:follow]
    menu_items << menu_item('page', 'new-window', :page=>card)                           if args[:show_menu_item][:page]
    menu_items << menu_item('account', 'user', :related=>{:name=>'+*account',:view=>:edit},
                                               :path_opts=>{:slot=>{:show=>:account_toolbar}})   if args[:show_menu_item][:account]
    menu_items << menu_item('', 'option-horizontal',:view=>home_view,
                                                    :path_opts=>{:slot=>{:show=>:toolbar}}) if args[:show_menu_item][:more]
    menu_items.map {|item| "<li class='#{args[:item_class]}'xy>#{item}</li>"}.join "\n"
  end


  def menu_item text, symbol, target
    link_text = "#{glyphicon(symbol)}<span class='menu-item-label'>#{text}</span>".html_safe
    if target[:view]
      view_link(link_text, target.delete(:view), target)
    elsif target[:page]
      card_link target.delete(:page), target.merge(:text=>link_text)
    elsif target[:related]
      target[:path_opts] ||= {}

      target[:path_opts][:related] =
        if target[:related].kind_of? String
          {:name=>"+#{target.delete(:related)}"}
        else
          target[:related]
        end
      view_link link_text, :related, target
    else
      link_to link_text, {:action=>target.delete(:action)}, target
    end
  end

  def default_vertical_menu_args args
    args.merge! :show_menu_item=>show_menu_items
  end
  def default_horizontal_menu_args args
    args.merge! :show_menu_item=>show_menu_items
  end

  def show_menu_items
    disc_tagname = Card.fetch(:discussion, :skip_modules=>true).cardname
    disc_card = unless card.new_card? or card.junction? && card.cardname.tag_name.key == disc_tagname.key
      Card.fetch "#{card.name}+#{disc_tagname}", :skip_virtual=>true, :skip_modules=>true, :new=>{}
    end

    res = {
      :structure  => card.structure && card.template.ok?(:update),
      :discuss    => disc_card && disc_card.ok?( disc_card.new_card? ? :comment : :read ),
      :page       => !main?,
      :more       => true
    }
    if card.real?
      res.merge!(
        :edit      => card.ok?(:update) || (card.structure && card.template.ok?(:update)),
        :account   => card.account && card.ok?(:update),
        :follow    => show_follow?,
        :delete    => card.ok?(:delete)
      )
    else
      res[:edit] = res[:structure]
    end
    res
  end


  view :toolbar do |args|
    content_tag :nav, :class=>"navbar navbar-inverse navbar-default slotter toolbar" do
      wrap_with(:p, :class=>"navbar-text navbar-left") do
        [
          _optional_render(:type_link,args,:show),
          _optional_render(:structure_link,args,:hide)
        ]
      end.concat %{
            <form class="navbar-form navbar-right" role="search">
                <div class="form-group">
                #{_optional_render :toolbar_buttons_advanced, args, :show}
                #{_optional_render :toolbar_buttons, args, :show}
                </div>
            </form>
          }.html_safe
    end
  end


  view :account_toolbar do |args|
    if card.accountable?
      links = []
      #user = subformat(card.left)
      links << related_link('*account',:text=>'account', :role=>'pill', 'data-toggle'=>'pill', :related_opts=>{:view=>:edit})
      links << related_link('*roles',  :text=>'roles',   :role=>'pill', 'data-toggle'=>'pill',)
      links << related_link('*created',:text=>'created', :role=>'pill', 'data-toggle'=>'pill' )
      links << related_link('*edited', :text=>'edited',  :role=>'pill', 'data-toggle'=>'pill' )
      links << related_link('*follow', :text=>'follow',  :role=>'pill', 'data-toggle'=>'pill' )
      list_items = "<li role='presentation' class='active'>#{links.shift}</li>\n"
      list_items += links.map {|item| "<li role='presentation'>#{item}</li>"}.join "\n"
      content_tag :nav, :class=>"navbar navbar-inverse navbar-default slotter toolbar" do
          %{
            <ul class="nav navbar-nav nav-pills">
            #{list_items}
            </ul>
          }.html_safe
        end

        #
        # ul.nav.nav-pills
        #      li.active(role='presentation')
        #        a(href='#beginner' role='pill' data-toggle='pill')
        #          | Beginner courses
        #      li(role='presentation')
        #        a(href='#expert' role='pill' data-toggle='pill')
        #          | Expert courses
    end
  end


  def btn_dropdown name, items
    dropdown = if items.kind_of? Array
        items.map {|item| "<li>#{item}</li>"}.join "\n"
      else
        items
      end
    %{
    <div class="btn-group" role="group">
        <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
         #{name}
         <span class="caret"></span>
       </button>
       <ul class="dropdown-menu" role="menu">
         #{dropdown}
       </ul>
    </div>
    }
  end

  # def btn_multidropdown name, menu
  #   dropdown =
  #     menu.map do |submenu|
  #       item = submenu.keys.first
  #       subitems = submenu[item]
  #       %{
  #         <li class="dropdown-submenu">
  #           <a href='#'>#{item}</a>
  #           <ul class="dropdown-menu">
  #             #{subitems.map { |subitem| "<li><a href='#'>#{subitem}</a></li>"}.join "\n"}
  #           </ul>
  #         </li>
  #       }
  #     end.join "\n"
  #   btn_dropdown name, dropdown
  # end

  view :toolbar_buttons do |args|
    wrap_with(:div, :class=>'btn-group') do
      [
        _optional_render(:history_button, args, :show),
        _optional_render(:delete_button, args, (card.ok?(:delete) ? :show : :hide)),
        _optional_render(:refresh_button, args)
      ]
    end
  end

  view :toolbar_buttons_advanced do |args|
    wrap_with(:div, :class=>'btn-group') do
      [
        _optional_render(:rules_button, args, :show),
        _optional_render(:related_button, args, :show),
      ]
    end
  end

  view :rules_button do |args|
    toolbar_button('rules', 'wrench', 'hidden-xs', :view=>'options')
  end

  view :related_button do |args|
    btn_dropdown(glyphicon('tree-deciduous')+' related', [
      menu_item('children', 'baby-formula', :related=>'*children'),
      menu_item('mates', 'bed', :related=>'*mates'),
      menu_item('references to', 'log-in', :related=>'*refers_to'),
      menu_item('references from', 'log-out', :related=>'*referred_to_by')
    ])
  end

  view :history_button do |args|
    toolbar_button('history', 'time', 'hidden-xs hidden-md hidden-lg', :view=>'history')
  end

  view :delete_button do |args|
    toolbar_button('delete', 'trash', 'hidden-xs hidden-md hidden-lg',
                    :action=>:delete,
                    :class => 'slotter standard-delete',
                    :remote => true,
                    :'data-confirm' => "Are you sure you want to delete #{card.name}?"
                  )
  end

  view :refresh_button do |args|
    toolbar_button('refresh', 'refresh', 'hidden-xs hidden-md hidden-lg', :view=>args[:home_view] || :open)
  end

  def toolbar_button text, symbol, hide, target
    btn_class = 'btn btn-default'
    link_text = "#{glyphicon symbol}<span class='menu-item-label #{hide}'>#{text}</span>"

    if target[:page]
      card_link target[:page], :class=>btn_class, :text=>link_text, :path_opts=>{:slot=>{:show=>:toolbar}}
    elsif target[:view]
      view_link link_text, target[:view], :class=>btn_class, :path_opts=>{:slot=>{:show=>:toolbar}}
    elsif target[:related]

    else
      target[:class] ||= ''
      target[:class] += " #{btn_class}"
      link_to link_text, {:action=>target.delete(:action)}, target
    end
  end

  view :type_link do |args|
    card_link(card.type_name, :text=>"Type: #{card.type_name}", :class=>'navbar-link') +
      view_link(glyphicon('edit'),'edit_type', :class=>'navbar-link slotter')
  end

  view :structure_link do |args|
    if card.structure && card.template.ok?(:update)
      card_link(card.structure, :text=>"Structure: #{card.structure.left.label}", :class=>'navbar-link') +
        card_link(card.structure, :path_opts=>{:view=>:edit}, :text=>glyphicon('edit'), :class=>'navbar-link')
    else
      ''
    end
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

