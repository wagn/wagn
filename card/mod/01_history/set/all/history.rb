ACTS_PER_PAGE = Card.config.acts_per_page

def history?
  true
end

# must be called on all actions and before :set_name, :process_subcards and
# :validate_delete_children

def actionable?
  history? || respond_to?(:attachment)
end

event :assign_action, :initialize,
      when: proc { |c| c.actionable? } do
  @current_act = director.need_act
  @current_action = Card::Action.create(
    card_act_id: @current_act.id,
    action_type: @action,
    draft: (Env.params['draft'] == 'true')
  )
  if @supercard && @supercard != self
    @current_action.super_action = @supercard.current_action
  end
end

def finalize_action?
  actionable? && current_action
end

# stores changes in the changes table and assigns them to the current action
# removes the action if there are no changes
event :finalize_action, :finalize,
      when: proc { |c| c.finalize_action? } do
  @changed_fields = Card::TRACKED_FIELDS.select do |f|
    changed_attributes.member? f
  end
  if @changed_fields.present?
    # FIXME: should be one bulk insert
    @changed_fields.each do |f|
      Card::Change.create field: f,
                          value: self[f],
                          card_action_id: @current_action.id
    end
    @current_action.update_attributes! card_id: id
  elsif @current_action.card_changes(true).empty?
    @current_action.delete
    @current_action = nil
  end
end

event :finalize_act,
      after: :finalize_action,
      when: proc { |c| !c.supercard } do
  if @current_act.actions(true).empty?
    @current_act.delete
    @current_act = nil
  else
    @current_act.update_attributes! card_id: id
  end
end

event :rollback_actions, :prepare_to_validate,
      on: :update,
      when: proc { |c| c.rollback_request? } do
  revision = { subcards: {} }
  rollback_actions = Env.params['action_ids'].map do |a_id|
    Action.fetch(a_id) || nil
  end
  rollback_actions.each do |action|
    if action.card_id == id
      revision.merge!(revision(action))
    else
      revision[:subcards][action.card.name] = revision(action)
    end
  end
  Env.params['action_ids'] = nil
  update_attributes! revision
  rollback_actions.each do |action|
    action.card.try :symlink_to, action.id
  end
  clear_drafts
  abort :success
end

def rollback_request?
  history? && Env && Env.params['action_ids'] &&
    Env.params['action_ids'].class == Array
end

# all acts with actions on self and on cards that are descendants of self and
# included in self
def intrusive_family_acts args={}
  @intrusive_family_acts ||= begin
    Act.find_all_with_actions_on((included_descendant_card_ids << id), args)
  end
end

# all acts with actions on self and on cards included in self
def intrusive_acts args={ with_drafts: true }
  @intrusive_acts ||= begin
    Act.find_all_with_actions_on((included_card_ids << id), args)
  end
end

def current_rev_nr
  @current_rev_nr ||= begin
    if intrusive_acts.first.actions.last.draft
      @intrusive_acts.size - 1
    else
      @intrusive_acts.size
    end
  end
end

def included_card_ids
  @included_card_ids ||=
    Card::Reference.select(:referee_id).where(
      ref_type: 'I', referer_id: id
    ).pluck('referee_id').compact.uniq
end

def descendant_card_ids parent_ids=[id]
  more_ids = Card.where('left_id IN (?)', parent_ids).pluck('id')
  more_ids += descendant_card_ids more_ids unless more_ids.empty?
  more_ids
end

def included_descendant_card_ids
  included_card_ids & descendant_card_ids
end

format :html do
  view :history do |args|
    frame args.merge(body_class: 'history-slot list-group', content: true) do
      [history_legend, _render_act_list]
    end
  end

  def default_history_args args
    args[:optional_toolbar] ||= :show
  end

  view :act_list do |args|
    page = params['page'] || 1
    count = card.intrusive_acts.size + 1 - (page.to_i - 1) * ACTS_PER_PAGE
    card.intrusive_acts.page(page).per(ACTS_PER_PAGE).map do |act|
      count -= 1
      render_act args.merge(act: act, act_seq: count, act_view: :summary)
    end.join
  end

  def history_legend
    intr = card.intrusive_acts.page(params['page']).per(ACTS_PER_PAGE)
    render_haml intr: intr do
      <<-HAML
.history-header
  %span.slotter
    = paginate intr, remote: true, theme: 'twitter-bootstrap-3'
  %div.history-legend
    %span.glyphicon.glyphicon-plus-sign.diff-green
    %span
      = Card::Diff.render_added_chunk('Added')
      |
    %span.glyphicon.glyphicon-minus-sign.diff-red
    %span
      = Card::Diff.render_deleted_chunk('Deleted')
      HAML
    end
  end

  def default_act_args args
    act = (args[:act] ||= Act.find(params['act_id']))
    args[:hide_diff]  ||= hide_diff?
    args[:slot_class] ||= "revision-#{act.id} history-slot list-group-item"
    args[:act_view]   ||= act_view
  end

  def hide_diff?
    params['hide_diff'].to_s.strip == 'true'
  end

  def act_view
    (params['act_view'] || 'summary').to_sym
  end

  view :act do |args|
    wrap(args) do
      render_haml args.merge(card: card, args: args) do
        <<-HAML
.act{style: "clear:both;"}
  .head
    .nr
      = "##{args[:act_seq]}"
    .title
      .actor
        = link_to act.actor.name, card_url(act.actor.cardname.url_key)
      .time.timeago
        = time_ago_in_words(act.acted_at)
        ago
        - if act.id == card.last_act.id
          %em.label.label-info Current
        - elsif act_view == :expanded
          = rollback_link act.relevant_actions_for(card)
          = show_or_hide_changes_link args
  .toggle
    = fold_or_unfold_link args
  .action-container{style: ("clear: left;" if act_view == :expanded)}
    - act.relevant_actions_for(card).each do |action|
      = send("_render_action_#{args[:act_view]}", action: action )
HAML
      end
    end
  end

  view :action_summary do |args|
    render_action :summary, args
  end

  view :action_expanded do |args|
    render_action :expanded, args
  end

  def render_action action_view, args
    action = args[:action] || card.last_action

    binding.pry if !action || !action.card

    hide_diff = Env.params['hide_diff'] == 'true' || args[:hide_diff]
    render_haml action: action,
                action_view: action_view,
                name_diff: name_diff(action, hide_diff),
                type_diff: type_diff(action, hide_diff),
                content_diff: content_diff(action, action_view, hide_diff) do
      <<-HAML
.action
  .summary
    %span.ampel
      = glyphicon 'minus-sign', (action.red? ? 'diff-red' : 'diff-invisible')
      = glyphicon 'plus-sign', (action.green? ? 'diff-green' : 'diff-invisible')
    = wrap_diff :name, name_diff
    = wrap_diff :type, type_diff
    -if content_diff
      = glyphicon 'arrow-right', 'arrow'
      -if action_view == :summary
        = wrap_diff :content, content_diff
  -if content_diff and action_view == :expanded
    .expanded
      = wrap_diff :content, content_diff
HAML
    end
  end

  def name_diff action, hide_diff
    if action.card == card
      name_changes(action, hide_diff)
    else
      link_path = path(
        view: :related,
        related: { view: 'history', name: action.card.name }
      )
      link_to name_changes(action, hide_diff), link_path,
              class: 'slotter label label-default',
              'data-slot-selector' => '.card-slot.history-view',
              remote: true
    end
  end

  def type_diff action, hide_diff
    action.new_type? && type_changes(action, hide_diff)
  end

  def content_diff action, action_view, hide_diff
    action.new_content? && action.card.format.render_content_changes(
      action: action, diff_type: action_view, hide_diff: hide_diff
    )
  end

  def wrap_diff field, content
    return '' unless content.present?
    %(
       <span class="#{field}-diff">
       #{content}
       </span>
    )
  end

  def name_changes action, hide_diff=false
    old_name = (name = action.previous_value :name) && showname(name).to_s
    if action.new_name?
      new_name = showname(action.value :name).to_s
      if hide_diff
        new_name
      else
        Card::Diff.complete(old_name, new_name)
      end
    else
      old_name
    end
  end

  def type_changes action, hide_diff=false
    change = hide_diff ? action.value(:cardtype) : action.cardtype_diff
    "(#{change})"
  end

  view :content_changes do |args|
    if args[:hide_diff]
      args[:action].value :db_content
    else
      args[:action].content_diff(args[:diff_type])
    end
  end

  def rollback_link actions
    not_current =
      actions.select { |action| action.card.last_action_id != action.id }
    return unless card.ok?(:update) && not_current.present?
    link_path = path action: :update, view: :open, action_ids: not_current
    '| ' + link_to(
      'Save as current', link_path,
      class: 'slotter', 'data-slot-selector' => '.card-slot.history-view',
      remote: true, method: :post, rel: 'nofollow'
    )
  end

  def fold_or_unfold_link args
    path_opts = {
      act_id: args[:act].id,
      act_view: (args[:act_view] == :expanded ? :summary : :expanded),
      hide_diff: args[:hide_diff]
    }
    arrow_dir = args[:act_view] == :expanded ? 'arrow-down' : 'arrow-right'
    view_link '', :act, path_opts: path_opts,
                        class: "slotter revision-#{args[:act_id]} #{arrow_dir}"
  end

  def show_or_hide_changes_link hide_diff, args
    text = (hide_diff ? 'Show' : 'Hide') + ' changes'
    '| ' + view_link(
      text, :act_expanded,
      path_opts: args.merge(hide_diff: !hide_diff),
      class: 'slotter', remote: true
    )
  end
end

def diff_args
  { format: :text }
end

def has_edits?
  Card::Act.where(actor_id: id).where('card_id IS NOT NULL').present?
end
