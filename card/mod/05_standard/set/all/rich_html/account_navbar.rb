format :html do
  view :account_navbar do |args|
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

  def account_pill name, active=false, path_opts={}
    opts = {:text=>name, :role=>'pill', :remote=>true, :path_opts=>path_opts}
    opts[:path_opts][:slot] ||= {}
    opts[:path_opts][:slot][:hide] = "toggle #{opts[:path_opts][:slot][:hide]}"
    li_pill card_link("#{card.name}+*#{name}", opts), active
  end

  def li_pill content, active
    "<li role='presentation' #{"class='active'" if active}>#{content}</li>"
  end

end