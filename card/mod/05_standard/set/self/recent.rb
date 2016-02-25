ACTS_PER_PAGE = 20


view :title do |args|
   super args.merge( title: 'Recent Changes' )
end

format :html do
  view :open do |args|
    frame args.merge(body_class: 'history-slot list-group', content: true) do
      [
        history_legend,
        _render_recent_acts
      ]
    end
  end

  view :recent_acts do |args|
    page = params['page'] || 1
    rpp = ACTS_PER_PAGE
    acts = Act.all.order(acted_at: :desc).page(page).per(rpp)
    acts.map do |act|
      render_complete_act_summary args.merge(act: act)
    end.join
  end

  view :complete_act_summary do |args|
    render_complete_act :summary, args
  end

  view :complete_act_expanded do |args|
    render_complete_act :expanded, args
  end


  def render_complete_act act_view, args
    act = (params['act_id'] && Card::Act.find(params['act_id'])) || args[:act]
    hide_diff = (params['hide_diff'] == ' true') || args[:hide_diff]
    args[:slot_class] = "revision-#{act.id} history-slot list-group-item"
    wrap(args) do
      render_haml card: card, act: act, act_view: act_view, hide_diff: hide_diff do
        <<-HAML
.act{style: "clear:both;"}
  .head
    .title
      .actor
        = card_link act.card  # (c = act.card) && (c.name)
      .time.timeago
        = time_ago_in_words(act.acted_at)
        ago
        by
        = link_to act.actor.name, card_url(act.actor.cardname.url_key)
        - if act_view == :expanded
          = rollback_link act.relevant_actions_for(card, draft)
          = show_or_hide_changes_link hide_diff, act_id: act.id, act_view: act_view
  .toggle
    = fold_or_unfold_link act_id: act.id, act_view: act_view
  .action-container{style: ("clear: left;" if act_view == :expanded)}
    - act.actions.each do |action|
      = send("_render_action_#{act_view}", action: action )
HAML
      end
    end
  end
end
