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

    link_to  glyphicon(direction),
             path( :view=>adjective ),
             :remote => true,
             :title => "#{verb} #{card.name}",
             :class => "#{verb}-icon toggler slotter nodblclick"
  end


  view :menu, :tags=>:unknown_ok do |args|
    return _render_template_closer if args[:menu_hack] == :template_closer
    _optional_render(:horizontal_menu, args,:hide) || _render_menu_link(args)
  end

  view :menu_link do |args|
    path_opts = {:slot => {:home_view=>args[:home_view]}}
    path_opts[:is_main] = true if main?
    content_tag :div, :class=>'btn-group pull-right slotter card-slot card-menu ' do
      view_link(glyphicon('cog'), :vertical_menu, :path_opts=>path_opts).html_safe
    end
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
        #{nest( card, :view=>:modal_slot) if args[:show_menu_item][:follow]
      }
      }.html_safe
    end
  end

  view :horizontal_menu do |args|
    content_tag :ul, :class=>'btn-group slotter pull-right card-menu horizontal-card-menu' do
      _render_menu_item_list(args.merge(:item_class=>'btn btn-default')).html_safe
    end.concat "#{nest( card, :view=>:modal_slot) if args[:show_menu_item][:follow]}".html_safe
  end

  view :menu_item_list do |args|
    disc_tagname = Card.fetch(:discussion, :skip_modules=>true).cardname
    home_view = args[:home_view] || :open
    menu_items = []
    menu_items << menu_item('edit', 'edit', :view=>:related,
                                            :path_opts=>{:related=>{:name=>card.name,:view=>:edit,:slot=>{:hide=>'header'}},
                                                         :slot=>{:show=>'edit_toolbar structure_link',
                                                                 :hide=>'type_link'}})           if args[:show_menu_item][:edit]
    menu_items << menu_item('discuss', 'comment', :related=>disc_tagname)                        if args[:show_menu_item][:discuss]
    menu_items << render_follow_modal_link                                                       if args[:show_menu_item][:follow]
    menu_items << menu_item('page', 'new-window', :page=>card)                                   if args[:show_menu_item][:page]
    menu_items << menu_item('account', 'user', :related=>{:name=>'+*account',:view=>:edit},
                                               :path_opts=>{:slot=>{:show=>:account_toolbar}})   if args[:show_menu_item][:account]
    menu_items << menu_item('', 'option-horizontal',:view=>home_view,
                                                    :path_opts=>{:slot=>{:show=>:toolbar}})      if args[:show_menu_item][:more]
    menu_items.map {|item| "<li class='#{args[:item_class]}'>#{item}</li>"}.join "\n"
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
      :structure  => show_structure?,
      :discuss    => disc_card && disc_card.ok?( disc_card.new_card? ? :comment : :read ),
      :page       => !main?,
      :more       => true
    }
    if card.real?
      res.merge!(
        :edit      => card.ok?(:update) || show_structure?,
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
    navbar 'toolbar', {}, :class=>"navbar-inverse slotter toolbar" do
      [
        (wrap_with(:p, :class=>"navbar-text navbar-left") do
          [
            _optional_render(:type_link,args,:show),
            _optional_render(:structure_link,args,:hide)
          ]
        end),
        (wrap_with :ul, :class=>'nav navbar-nav navbar-right' do
          wrap_each_with :li do
            [
              view_link(glyphicon('remove'), :open)
            ]
          end
        end),
        %{
          <form class="navbar-form navbar-right" role="search">
              <div class="form-group">
              #{_optional_render :toolbar_buttons_advanced, args, :show}
              #{_optional_render :toolbar_buttons, args, :show}
              </div>
          </form>
        }.html_safe,
      ]
    end
  end

  view :edit_toolbar do |args|
    navbar 'edit-toolbar', {}, :class=>'navbar-inverse slotter toolbar' do
      [
        content_tag(:span, 'Edit:', :class=>"navbar-text"),
        (wrap_with :ul, :class=>'nav navbar-nav nav-pills' do
          [
            _optional_render(:edit_content_button, args, :show),
            _optional_render(:edit_name_button,    args, :show),
            _optional_render(:edit_type_button,    args, :show),
            _optional_render(:edit_rules_button,   args, :show),
            _optional_render(:edit_nests_button,   args, :show),
          ]
        end),
        (wrap_with :ul, :class=>'nav navbar-nav navbar-right' do
          wrap_each_with :li do
            [
              (view_link('autosaved draft', :edit, :path_opts=>{:edit_draft=>true, :slot=>{:show=>:edit_toolbar}}, :class=>'navbar-link slotter') if card.drafts.present?),
              view_link(glyphicon('remove'), :open)
            ]
          end
        end),
      ]
    end
  end

  view :account_toolbar do |args|
    if card.accountable?
      links = []
      links << account_pill( 'account', true, :view=>:edit)
      links << account_pill( 'roles')
      links << account_pill( 'created')
      links << account_pill( 'edited')
      links << account_pill( 'follow')
      navbar 'account-toolbar', {}, :class=>"navbar-inverse slotter toolbar", 'data-slot-selector'=>'.related-view > .card-body > .card-slot' do
        [
          content_tag(:ul, links.join("\n").html_safe, :class=>'nav navbar-nav nav-pills'),
          content_tag(:ul, "<li>#{view_link(glyphicon('remove'), :open)}</li>".html_safe, :class=>'nav navbar-nav navbar-right'),
        ]
      end
    end
  end

  view :toolbar_buttons do |args|
    wrap_with(:div, :class=>'btn-group') do
      [
        _optional_render(:history_button, args, :show),
        _optional_render(:delete_button,  args, (card.ok?(:delete) ? :show : :hide)),
        _optional_render(:refresh_button, args)
      ]
    end
  end

  view :toolbar_buttons_advanced do |args|
    wrap_with(:div, :class=>'btn-group') do
      [
        _optional_render(:rules_button,   args, :show),
        _optional_render(:related_button, args, :show),
      ]
    end
  end

  view :edit_toolbar_buttons do |args|
    wrap_with(:div, :class=>'btn-group') do
      [
        _optional_render(:edit_content_button,   args, :show),
        _optional_render(:edit_structure_button, args, :show),
        _optional_render(:edit_name_button,      args, :show),
        _optional_render(:edit_type_button,      args, :show),
      ]
    end
  end

  view :rules_button do |args|
    toolbar_button('rules', 'wrench', 'hidden-xs', :view=>'options')
  end
  view :related_button do |args|
    btn_dropdown(glyphicon('tree-deciduous')+' related', [
      menu_item('children',        'baby-formula', :related=>'*children'),
      menu_item('mates',           'bed',          :related=>'*mates'),
      menu_item('references to',   'log-in',       :related=>'*refers_to'),
      menu_item('references from', 'log-out',      :related=>'*referred_to_by')
    ], :class=>'related')
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


  view :edit_content_button do |args|
    pill_view_link( 'content', 'edit', true)
  end
  view :edit_name_button do |args|
    pill_view_link( 'name','edit_name')
  end
  view :edit_type_button do |args|
    pill_view_link( 'type', 'edit_type')
  end
  view :edit_rules_button do |args|
    if show_structure?
      rule_items = []
      rule_items << pill_card_link('structure', card.structure, false, :view=>:edit, :slot=>{:hide=>:toggle})
      rule_items << pill_view_link('...', 'options')
      pill_dropdown('rules', rule_items)
    else
      pill_view_link('rules', 'options')
    end
  end
  view :edit_nests_button do |args|
    if (nests = card.fetch(:trait=>:includes)) && nests.item_names.present?
      pill_card_link('nests', nests, false,  :slot=>{:hide=>'header', :items=>{:view=>:options, :unlabeled=>true, :hide=>'permission communication other style layout script table_of_contents'}})
    end
  end


  view :type_link do |args|
    card_link(card.type_name, :text=>"Type: #{card.type_name}", :class=>'navbar-link') +
      view_link(glyphicon('edit'),'edit_type', :class=>'navbar-link slotter', 'data-toggle'=>'tooltip', :title=>'edit type')
  end

  view :structure_link do |args|
    if show_structure?
      card_link(card.structure, :text=>"Structure: #{card.structure.left.label}", :class=>'navbar-link') +
        card_link(card.structure, :path_opts=>{:view=>:edit}, :text=>glyphicon('edit'), :class=>'navbar-link')
    else
      ''
    end
  end


  def toolbar_button text, symbol, hide, target
    btn_class = 'btn btn-default'
    link_text = "#{glyphicon symbol}<span class='menu-item-label #{hide}'>#{text}</span>"

    if target[:page]
      card_link target[:page], :class=>btn_class, :text=>link_text, :path_opts=>{:slot=>{:show=>:toolbar}}
    elsif target[:view]
      view_link link_text, target[:view], :class=>btn_class, :path_opts=>{:slot=>{:show=>:toolbar}}
    else
      target[:class] ||= ''
      target[:class] += " #{btn_class}"
      link_to link_text, {:action=>target.delete(:action)}, target
    end
  end

  def pill_view_link name, view, active=false, path_opts={}
    opts = {:class=>'slotter', 'data-slot-selector'=>'.related-view > .card-body > .card-slot', :role=>'pill',
            :path_opts=>path_opts.merge(:slot=>{:hide=>'toggle menu header'})}
    link = view_link name, view, opts
    "<li role='presentation' #{"class='active'" if active}>#{link}</li>"
  end

  def pill_card_link name, card, active=false, path_opts={}
    opts = {:text=>name, :class=>'slotter', 'data-slot-selector'=>'.related-view > .card-body > .card-slot', :role=>'pill', :remote=>true,
            :path_opts=>path_opts}
    link = card_link card, opts
    "<li role='presentation' #{"class='active'" if active}>#{link}</li>"
  end


  def account_pill name, active=false, path_opts={}
    opts = {:role=>'pill', :remote=>true, :text=>name, :path_opts=>path_opts.merge(:slot=>{:hide=>:toggle})}
    link = card_link "#{card.name}+*#{name}", opts
    "<li role='presentation' #{"class='active'" if active}>#{link}</li>"
  end

  def pill_dropdown name, items
    %{
      <li role="presentation" class="dropdown">
        <a class="dropdown-toggle" data-toggle="dropdown" href="#" role="button" aria-expanded="false">
          #{name} <span class="caret"></span>
        </a>
        <ul class="dropdown-menu" role="menu">
          #{items.map {|item| "<li>#{item}</li>"}.join "\n"}
        </ul>
      </li>
    }
  end


  def btn_dropdown name, items, opts={}
    dropdown =
      if items.kind_of? Array
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
        <ul class="dropdown-menu #{opts[:class] if opts[:class]}" role="menu">
          #{dropdown}
        </ul>
      </div>
    }
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

  def show_structure?
    card.structure && card.template.ok?(:update)
  end

end

