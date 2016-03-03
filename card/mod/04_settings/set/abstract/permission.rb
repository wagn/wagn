
def standardize_items
  # noop to override default behavior, which wouldn't let '_left' through and would therefore break
end

format :html do
  view :pointer_core do |args| # view: :core, mod: Type::Pointer::HtmlFormat
    %(<div class="pointer-list">#{render_pointer_items args}</div>)
  end

  view :core do |args|
    if card.content == '_left'
      core_inherit_content args
    else
      render :pointer_core, args
    end
  end

  view :closed_content do |args|
    args[:item] ||= :link
    render_core args
  end

  view :editor do |args|
    set_name = card.cardname.trunk_name
    set_card = Card.fetch(set_name)
    not_set = set_card && set_card.type_id != SetID

    group_options = Auth.as_bot do
      Card.search({ type_id: RoleID, sort: 'name' }, 'roles by name')
    end

    inheritable = not_set ? false : set_card.inheritable?
    inheriting = inheritable && card.content == '_left'

    item_names = inheriting ? [] : card.item_names

    %(
      #{hidden_field :content, class: 'card-content'}
      <div class="perm-editor">

        #{if inheritable; %(
          <div class="perm-inheritance perm-section">
            #{check_box_tag 'inherit', 'inherit', inheriting}
            <label>
              #{core_inherit_content args.merge(target: 'wagn_role')}
              #{content_tag(:a, title: "use left's #{card.cardname.tag} rule") { '?' }}
            </label>
          </div>
        ) end}

        <div class="perm-group perm-vals perm-section">
          <h5>Groups</h5>
          #{group_options.map do |option|
              checked = !!item_names.delete(option.name)
              %(
                <div class="group-option">
                  #{check_box_tag("#{option.key}-perm-checkbox", option.name, checked, class: 'perm-checkbox-button')}
                  <label>#{card_link option.name, target: 'wagn_role'}</label>
                </div>
              )
            end * "\n"}
        </div>

        <div class="perm-indiv perm-vals perm-section">
          <h5>Individuals</h5>
          #{_render_list item_list: item_names, extra_css_class: 'perm-indiv-ul'}
        </div>

      </div>
    )
  end

  private

  def core_inherit_content args={}
    sc = args[:set_context]
    text = if sc && sc.tag_name.key == Card[:self].key
             begin
               task = card.tag.codename
               ancestor = Card[sc.trunk_name.trunk_name]
               links = ancestor.who_can(task.to_sym).map do |card_id|
                 card_link Card[card_id].name, target: args[:target]
               end * ', '
               "Inherit ( #{links} )"
             rescue
               'Inherit'
             end
           else
             'Inherit from left card'
    end
    %(<span class="inherit-perm">#{text}</span>)
  end
end
