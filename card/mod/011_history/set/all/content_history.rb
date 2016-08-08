
# if these aren't in a nested module, the methods just overwrite the base
#  methods, but we need a distict module so that super will be able to refer to
# the base methods.
def content
  if @selected_action_id
    @selected_content ||= begin
      change = last_change_on :db_content, not_after: @selected_action_id,
                                           including_drafts: true
      (change && change.value) || db_content
    end
  else
    super
  end
end

def content= value
  @selected_content = nil
  super
end

def save_content_draft content
  super
  acts.create do |act|
    act.actions.build(draft: true, card_id: id)
       .card_changes.build(field: :db_content, value: content)
  end
end

def last_change_on field, opts={}
  where_sql = "card_actions.card_id = :card_id AND field = :field"
  where_sql += " AND (draft is not true)" unless opts[:including_drafts]
  if opts[:before]
    where_sql += " AND card_action_id < :action_id"
  elsif opts[:not_after]
    where_sql += " AND card_action_id <= :action_id"
  end

  action_arg = opts[:before] || opts[:not_after]
  action_id = action_arg.is_a?(Card::Action) ? action_arg.id : action_arg
  Change.joins(:action).where(
    where_sql, card_id: id,
               field: Card::Change.field_index(field),
               action_id: action_id
  ).order(:id).last
end

def selected_action_id
  @selected_action_id || (@current_action && @current_action.id) ||
    last_action_id
end

def selected_action_id= action_id
  @selected_content = nil
  @selected_action_id = action_id
end

def selected_action
  selected_action_id && Action.fetch(selected_action_id)
end

def with_selected_action_id action_id
  current_action_id = @selected_action_id
  run_callbacks :select_action do
    self.selected_action_id = action_id
  end
  result = yield
  run_callbacks :select_action do
    self.selected_action_id = current_action_id
  end
  result
end

def selected_content_action_id
  @selected_action_id || new_content_action_id || last_content_action_id
end

def new_content_action_id
  if @current_action && (new_card? || @current_action.new_content? ||
     db_content_changed?)
    @current_action.id
  end
end

def last_action_id
  (la = last_action) && la.id
end

def last_action
  actions.where("id IS NOT NULL").last
end

def last_content_action
  l_c = last_change_on :db_content
  l_c && l_c.action
end

def last_content_action_id
  l_c = last_change_on :db_content
  l_c && l_c.card_action_id
end

def last_actor
  last_act.actor
end

def last_act
  @last_act ||=
    if (action = last_action)
      last_act_on_self = acts.last
      if last_act_on_self &&
         (action.act == last_act_on_self ||
         last_act_on_self.acted_at > action.act.acted_at)
        last_act_on_self
      else
        action.act
      end
    end
end

def acted_at
  last_act.acted_at
end

def previous_action action_id
  if action_id
    action_index = actions.find_index do |a|
      a.id == action_id
    end
    actions[action_index - 1] if action_index.to_i != 0
  end
end

def revised_at
  (last_action && (act = last_action.act) && act.acted_at) || Time.zone.now
end

def creator
  Card[creator_id]
end

def updater
  Card[updater_id]
end

def clean_html?
  true
end

def draft_acts
  drafts.created_by(Card::Auth.current_id).map(&:act)
end

event :detect_conflict, :validate,
      on: :update, when: proc { |c| c.history? } do
  if last_action_id_before_edit &&
     last_action_id_before_edit.to_i != last_action_id &&
     last_action.act.actor_id != Auth.current_id
    errors.add :conflict, "changes not based on latest revision"
  end
end
