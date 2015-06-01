
format :html do
  def edit_toolbar_pinned?
    Card[:edit_toolbar_pinned].content == 'true'
  end

  def toolbar_pinned?
    Card[:toolbar_pinned].content == 'true'
  end

  view :toolbar do |args|
    navbar "toolbar-#{card.cardname.safe_key}-#{args[:home_view]}", :toggle_align=>:left, :class=>"slotter toolbar", :navbar_type=>'inverse',
          :collapsed_content=>close_link('pull-right visible-xs') do
      [
        (wrap_with(:p, :class=>"navbar-text navbar-left") do
          _optional_render(:type_link,args,:show)
        end),
        close_link('hidden-xs navbar-right'),
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

  def close_link css_class
    wrap_with :ul, :class=>"nav navbar-nav #{css_class}" do
      [
        toolbar_pin_link,
        "<li>#{view_link(glyphicon('remove'), :home, :title=>'cancel')}</li>"
      ]
    end
  end

  view :edit_toolbar do |args|
    id = "edit-toolbar-#{card.cardname.safe_key}-#{args[:home_view]}"
    navbar_right = ''
    navbar_right += edit_toolbar_autosave_link if card.drafts.present?
    navbar_right += edit_toolbar_pin_link
    navbar_right += edit_toolbar_close_link

    navbar id, :toggle=>'Edit<span class="caret"></span>', :toggle_align=>:left,
               :class=>'slotter toolbar', :navbar_type=>'inverse', :collapsed_content=>close_link('pull-right visible-xs') do
      [
        content_tag(:span, 'Edit:', :class=>"navbar-text hidden-xs"),
        (wrap_with :ul, :class=>'nav navbar-nav nav-pills' do
          [
            _optional_render(:edit_content_button, args, :show),
            _optional_render(:edit_name_button,    args, :show),
            _optional_render(:edit_type_button,    args, :show),
            _optional_render(:edit_rules_button,   args, :show),
            _optional_render(:edit_nests_button,   args, :show),
            _optional_render(:edit_history_button, args, :show),
            _optional_render(:edit_delete_button, args, (card.ok?(:delete) ? :show : :hide)),
          ]
        end),
        content_tag( :ul, navbar_right.html_safe, :class=>'nav navbar-nav navbar-right' )
      ]
    end
  end

  view :account_toolbar do |args|
    if card.accountable?
      links = []
      links << account_pill( 'account', true, :view=>:edit, :slot=>{:hide=>'edit_toolbar'})
      links << account_pill( 'roles')
      links << account_pill( 'created')
      links << account_pill( 'edited')
      links << account_pill( 'follow')
      navbar 'account-toolbar',:toggle_align=>:left, :collapsed_content=>close_link('pull-right visible-xs'), :navbar_type=>'inverse',
      :class=>"slotter toolbar", :navbar_opts=>{'data-slot-selector'=>'.card-slot.related-view > .card-frame > .card-body > .card-slot'} do
        [
          content_tag(:ul, links.join("\n").html_safe, :class=>'nav navbar-nav nav-pills'),
          content_tag(:ul, "<li>#{view_link(glyphicon('remove','hidden-xs'), :open)}</li>".html_safe, :class=>'nav navbar-nav navbar-right'),
        ]
      end
    end
  end

  view :toolbar_buttons do |args|
    wrap_with(:div, :class=>'btn-group') do
      [
        _optional_render(:history_button, args, :show),
        _optional_render(:delete_button,  args, (card.ok?(:delete) ? :show : :hide)),
        _optional_render(:refresh_button, args, :hide)
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
    toolbar_button('rules', 'wrench', 'hidden-xs hidden-sm', :view=>'options')
  end
  view :related_button do |args|
    path_opts = {:slot=>{:show=>:toolbar}}
    btn_dropdown('related', 'tree-deciduous', [
      menu_item('children',       'baby-formula', {:related=>'*children', :path_opts=>path_opts}),
      menu_item('mates',          'bed',          {:related=>'*mates', :path_opts=>path_opts}),
      menu_item('references out', 'log-out',      {:related=>'*refers_to', :path_opts=>path_opts}),
      menu_item('references in',  'log-in',       {:related=>'*referred_to_by', :path_opts=>path_opts})

    ], :class=>'related')
  end
  view :history_button do |args|
    toolbar_button('history', 'time', 'hidden-xs hidden-sm hidden-md', :view=>'history')
  end
  view :delete_button do |args|
    toolbar_button('delete', 'trash', 'hidden-xs hidden-sm hidden-md hidden-lg',
                    :action=>:delete,
                    :class => 'slotter',
                    :remote => true,
                    :path_opts=> {:success => main? ? 'REDIRECT: *previous' : "TEXT: #{card.name} deleted"},
                    :'data-confirm' => "Are you sure you want to delete #{card.name}?"
                  )
  end
  view :refresh_button do |args|
    toolbar_button('refresh', 'refresh', 'hidden-xs hidden-sm hidden-md hidden-lg', :view=>args[:home_view] || :open)
  end

  view :edit_content_button do |args|
    pill_view_link 'content', :edit, args
  end
  view :edit_name_button do |args|
    pill_view_link 'name',:edit_name, args
  end
  view :edit_type_button do |args|
    pill_view_link 'type', :edit_type, args
  end
  view :edit_rules_button do |args|
    if structure_editable?
      active = [:edit_rules, :edit_structure].include? args.delete(:active_toolbar_view)
      rule_items = pill_view_link 'structure', :edit_structure, args
      rule_items += pill_view_link '...', :edit_rules, args
      pill_dropdown 'rules', rule_items, active
    else
      pill_view_link 'rules', :edit_rules, args
    end
  end
  view :edit_nests_button do |args|
    if (nests = card.fetch(:trait=>:includes)) && nests.item_names.present?
      pill_view_link 'nests', :edit_nests, args
    end
  end
  view :edit_history_button do |args|
    active_view = args[:active_toolbar_view] || args[:home_view]
    link = view_link "#{glyphicon('time')} history", :history, :class=>'slotter navbar-divide', :role=>'pill'
    li_pill link, active_view == :history
  end
  view :edit_delete_button do |args|
    active_view = args[:active_toolbar_view] || args[:home_view]
    link = link_to  glyphicon('trash'),{:action=>:delete, :success => main? ? 'REDIRECT: *previous' : "TEXT: #{card.name} deleted"},
                    :role=>'pill',
                    :class => 'slotter',
                    :remote => true,
                    :'data-confirm' => "Are you sure you want to delete #{card.name}?"
    li_pill link, false
  end

  view :type_link do |args|
    card_link(card.type_name, :text=>"Type: #{card.type_name}", :class=>'navbar-link') +
      view_link(glyphicon('edit'),'edit_type', :class=>'navbar-link slotter', 'data-toggle'=>'tooltip', :title=>'edit type')
  end

  def toolbar_button text, symbol, hide, tag_args
    tag_args[:class] = [ tag_args[:class], 'btn btn-default' ].compact * ' '
    tag_args[:title] ||= text
    link_text = "#{glyphicon symbol}<span class='menu-item-label #{hide}'>#{text}</span>"

    if cardname = tag_args.delete(:page)
      card_link cardname, :class=>klass, :text=>link_text
    elsif viewname = tag_args.delete(:view)
      tag_args[:path_opts] ||= {:slot=>{:show=>:toolbar}}
      view_link link_text, viewname, tag_args
    else
      path_opts = tag_args.delete(:path_opts) || {}
      path_opts.merge! :action=>tag_args.delete(:action)
      link_to link_text, path_opts, tag_args
    end
  end

  def pill_view_link name, view, args
    active_view = args[:active_toolbar_view] || args[:home_view]
    opts = {:class=>'slotter', :role=>'pill'}
    li_pill view_link(name, view, opts), active_view == view
  end

  def account_pill name, active=false, path_opts={}
    opts = {:text=>name, :role=>'pill', :remote=>true, :path_opts=>path_opts}
    opts[:path_opts][:slot] ||= {}
    opts[:path_opts][:slot][:hide] = "toggle #{opts[:path_opts][:slot][:hide]}"
    li_pill card_link("#{card.name}+*#{name}", opts), active
  end

  def li_pill content, active
    "<li role='presentation' #{"class='active'" if active}>#{content}</li>"
  end

  def pill_dropdown name, items, active=false
    %{
      <li role="presentation" class="dropdown #{'active' if active}">
        <a class="dropdown-toggle" data-toggle="dropdown" href="#" role="button" aria-expanded="false">
          #{name} <span class="caret"></span>
        </a>
        #{ dropdown_list items }
      </li>
    }
  end

  def btn_dropdown name, icon, items, opts={}
    %{
      <div class="btn-group" role="group">
        <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown" title="#{name}" aria-expanded="false">
          #{glyphicon icon} #{name}
          <span class="caret"></span>
        </button>
        #{ dropdown_list items, opts[:class] }
      </div>
    }
  end

  def dropdown_list items, extra_css_class=nil
    if items.kind_of? Array
      items = items.map {|item| "<li>#{item}</li>"}.join "\n"
    end
    %{
      <ul class="dropdown-menu #{extra_css_class}" role="menu">
        #{items}
      </ul>
    }
  end

  def toolbar_pin_link
    %{
      <li class='toolbar-pin #{'in' unless toolbar_pinned?}active'>
        <a href='#' title='#{'un' if toolbar_pinned?}pin'>#{glyphicon 'pushpin'}</a>
      </li>
    }
  end

  def edit_toolbar_pin_link
    %{
      <li class='edit-toolbar-pin #{'in' unless edit_toolbar_pinned?}active'>
        <a href='#' title='#{'un' if edit_toolbar_pinned?}pin'>#{glyphicon 'pushpin'}</a>
      </li>
    }
  end

  def edit_toolbar_close_link
    link = view_link glyphicon('remove', 'hidden-xs'), :home, :path_opts=>{:slot=>{:hide=>:edit_toolbar}}
    "<li>#{link}</li>"
  end

  def edit_toolbar_autosave_link
    link = view_link('autosaved draft', :edit, :path_opts=>{:edit_draft=>true, :slot=>{:show=>:edit_toolbar}}, :class=>'navbar-link slotter')
    "<li>#{link}</li>"
  end

end
