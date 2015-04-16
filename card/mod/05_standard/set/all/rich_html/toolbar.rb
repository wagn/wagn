format :html do
  view :toolbar do |args|
    navbar 'toolbar', {}, :class=>"slotter toolbar", :navbar_type=>'inverse' do
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
          <form class="navbar-form navbar-right">
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
    navbar 'edit-toolbar', {}, :class=>'slotter toolbar', :navbar_type=>'inverse' do
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
      navbar 'account-toolbar', {}, :navbar_type=>'inverse', :class=>"slotter toolbar", 'data-slot-selector'=>'.related-view > .card-body > .card-slot' do
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
      pill_card_link('nests', nests, false,  :slot=>{:hide=>'header', :items=>{:view=>:options, :hide=>'set_label'}})
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
    opts = {:class=>'slotter', :role=>'pill', 'data-slot-selector'=>'.related-view > .card-body > .card-slot',
            :path_opts=>path_opts.merge(:slot=>{:hide=>'toggle menu header'})}
    li_pill view_link(name, view, opts), active
  end

  def pill_card_link name, card, active=false, path_opts={}
    opts = {:text=>name, :role=>'pill', :remote=>true, :class=>'slotter', 'data-slot-selector'=>'.related-view > .card-body > .card-slot',
            :path_opts=>path_opts}
    li_pill card_link(card, opts), active
  end

  def account_pill name, active=false, path_opts={}
    opts = {:text=>name, :role=>'pill', :remote=>true,
            :path_opts=>path_opts.merge(:slot=>{:hide=>:toggle})}
    li_pill card_link("#{card.name}+*#{name}", opts), active
  end

  def li_pill content, active
    "<li role='presentation' #{"class='active'" if active}>#{content}</li>"
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
end
