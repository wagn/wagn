format :html do
  view :menu, :tags=>:unknown_ok do |args|
    return _render_template_closer if args[:menu_hack] == :template_closer
    _optional_render(:horizontal_menu, args, :hide) || _render_menu_link(args)
  end

  view :menu_link do |args|
    path_opts = {:slot => {:home_view=>args[:home_view]}}
    path_opts[:is_main] = true if main?
    content_tag :div, :class=>'btn-group pull-right slotter card-slot card-menu vertical-card-menu' do
      view_link(glyphicon(args[:menu_icon]), :vertical_menu, :path_opts=>path_opts).html_safe
    end
  end

  view :vertical_menu, :tags=>:unknown_ok do |args|
    items = menu_item_list(args).map {|item| "<li class='#{args[:item_class]}'>#{item}</li>"}.join "\n"
    content_tag :ul, :class=>'btn-group slotter pull-right card-menu vertical-card-men' do
      %{
        <span class="open-menu dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
          <a href='#'>#{ glyphicon args[:menu_icon] }</a>
        </span>
        <ul class="dropdown-menu" role="menu">
          #{ items }
        </ul>
        #{ _render_modal_slot(args) if args[:show_menu_item][:follow] }
      }.html_safe
    end
  end

  view :horizontal_menu do |args|
    content_tag :div, :class=>'btn-group slotter pull-right card-menu horizontal-card-menu' do
      menu_item_list(args.merge(:html_args=>{:class=>'btn btn-default'})).join("\n").html_safe
    end.concat "#{ _render_modal_slot(args) if args[:show_menu_item][:follow]}".html_safe
  end

  def menu_item_list args
    menu_items = []
    menu_items << menu_edit_link(args)            if args[:show_menu_item][:edit]
    menu_items << menu_discuss_link(args)         if args[:show_menu_item][:discuss]
    menu_items << _render_follow_modal_link(args) if args[:show_menu_item][:follow]
    menu_items << menu_page_link(args)            if args[:show_menu_item][:page]
    menu_items << menu_account_link(args)         if args[:show_menu_item][:account]
    menu_items << menu_more_link(args)            if args[:show_menu_item][:more]
    menu_items
  end

  def menu_edit_link args
    opts = {
             :view=>:related,
             :path_opts=>{ :related=>{:name=>card.name, :view=>:edit, :slot=>{:hide=>'header'}},
                           :slot=>{:show=>'edit_toolbar structure_link', :hide=>'type_link'}}
           }
    menu_item('edit', 'edit', opts, args[:html_args] )
  end

  def menu_discuss_link args
    disc_tagname = Card.fetch(:discussion, :skip_modules=>true).name
    menu_item('discuss', 'comment', {:related=>disc_tagname}, args[:html_args])
  end

  def menu_page_link args
    menu_item('page', 'new-window', {:page=>card}, args[:html_args])
  end

  def menu_account_link args
    opts = { :related=>{:name=>'+*account',:view=>:edit},
             :path_opts=>{:slot=>{:show=>:account_toolbar}} }
    menu_item('account', 'user',opts, args[:html_args])
  end

  def menu_more_link args
    opts = { :view=>args[:home_view] || :open,
             :path_opts=>{:slot=>{:show=>:toolbar}}}
    menu_item('', 'option-horizontal', opts, args[:html_args])
  end

  def menu_item text, icon, target, html_args=nil
    link_text = "#{glyphicon(icon)}<span class='menu-item-label'>#{text}</span>".html_safe
    target.merge!(html_args) if html_args
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

  def default_menu_link_args args
    args[:menu_icon] ||= 'cog'
  end

  def default_vertical_menu_args args
    default_menu_link_args args
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
      :more       => !card.new_card?
    }
    if card.real?
      res.merge!(
        :edit      => !card.new_card? && (card.ok?(:update) || show_structure?),
        :account   => card.account && card.ok?(:update),
        :follow    => show_follow?,
        :delete    => card.ok?(:delete)
      )
    else
      res[:edit] = !card.new_card? && res[:structure]
    end
    res
  end
end
